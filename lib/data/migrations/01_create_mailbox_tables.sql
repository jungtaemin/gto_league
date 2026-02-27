-- Create user_mail table (Mailbox system)
CREATE TABLE IF NOT EXISTS public.user_mail (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('system', 'event', 'compensation', 'announcement')),
    title TEXT NOT NULL,
    body TEXT NOT NULL DEFAULT '',
    reward_chips INTEGER DEFAULT 0,
    reward_energy INTEGER DEFAULT 0,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    claimed_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- RLS Policies
ALTER TABLE public.user_mail ENABLE ROW LEVEL SECURITY;

-- user_mail: Users can read their own mail
CREATE POLICY "Users can view own mail" ON public.user_mail FOR SELECT USING (auth.uid() = user_id);
-- user_mail: Users can update their own mail (mark as read, claim rewards)
CREATE POLICY "Users can update own mail" ON public.user_mail FOR UPDATE USING (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_mail_user_id ON public.user_mail(user_id);
CREATE INDEX IF NOT EXISTS idx_user_mail_created_at ON public.user_mail(created_at DESC);

-- RPC function: Claim a single mail reward (atomic, idempotent)
CREATE OR REPLACE FUNCTION public.claim_mail_reward(p_mail_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_mail RECORD;
    v_reward_chips INTEGER;
    v_reward_energy INTEGER;
BEGIN
    -- Atomically claim the mail (only if not already claimed)
    UPDATE public.user_mail
    SET claimed_at = timezone('utc'::text, now())
    WHERE id = p_mail_id
      AND user_id = auth.uid()
      AND claimed_at IS NULL
    RETURNING reward_chips, reward_energy INTO v_reward_chips, v_reward_energy;

    -- If no rows were updated, mail was already claimed or doesn't exist
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Mail not found or already claimed'
        );
    END IF;

    -- Apply rewards to profiles
    IF v_reward_chips > 0 THEN
        UPDATE public.profiles
        SET chips = chips + v_reward_chips
        WHERE id = auth.uid();
    END IF;

    IF v_reward_energy > 0 THEN
        UPDATE public.profiles
        SET energy = energy + v_reward_energy
        WHERE id = auth.uid();
    END IF;

    -- Return the claimed mail data
    RETURN jsonb_build_object(
        'success', true,
        'mail_id', p_mail_id,
        'reward_chips', v_reward_chips,
        'reward_energy', v_reward_energy,
        'claimed_at', timezone('utc'::text, now())
    );
END;
$$;

-- RPC function: Claim all unclaimed mail rewards for a user (bulk operation)
CREATE OR REPLACE FUNCTION public.claim_all_mail_rewards(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_total_chips INTEGER := 0;
    v_total_energy INTEGER := 0;
    v_claim_count INTEGER := 0;
BEGIN
    -- Only allow users to claim their own rewards
    IF auth.uid() != p_user_id THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Unauthorized: cannot claim rewards for another user'
        );
    END IF;

    -- Calculate totals from unclaimed mail
    SELECT
        COALESCE(SUM(reward_chips), 0),
        COALESCE(SUM(reward_energy), 0),
        COUNT(*)
    INTO v_total_chips, v_total_energy, v_claim_count
    FROM public.user_mail
    WHERE user_id = p_user_id
      AND claimed_at IS NULL;

    -- Mark all unclaimed mail as claimed
    UPDATE public.user_mail
    SET claimed_at = timezone('utc'::text, now())
    WHERE user_id = p_user_id
      AND claimed_at IS NULL;

    -- Apply total rewards to profiles
    IF v_total_chips > 0 THEN
        UPDATE public.profiles
        SET chips = chips + v_total_chips
        WHERE id = p_user_id;
    END IF;

    IF v_total_energy > 0 THEN
        UPDATE public.profiles
        SET energy = energy + v_total_energy
        WHERE id = p_user_id;
    END IF;

    -- Return summary
    RETURN jsonb_build_object(
        'success', true,
        'claim_count', v_claim_count,
        'total_chips', v_total_chips,
        'total_energy', v_total_energy,
        'claimed_at', timezone('utc'::text, now())
    );
END;
$$;
