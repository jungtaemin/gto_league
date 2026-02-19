-- Create decorate_items table (Master data)
CREATE TABLE IF NOT EXISTS public.decorate_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    type TEXT NOT NULL CHECK (type IN ('character', 'frame', 'card_skin', 'title')),
    name TEXT NOT NULL,
    asset_url TEXT NOT NULL,
    rarity TEXT DEFAULT 'common' CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create user_items table (Inventory)
CREATE TABLE IF NOT EXISTS public.user_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    item_id UUID REFERENCES public.decorate_items(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, item_id)
);

-- Create user_equipped table (Current Loadout)
CREATE TABLE IF NOT EXISTS public.user_equipped (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    character_id UUID REFERENCES public.decorate_items(id) ON DELETE SET NULL,
    frame_id UUID REFERENCES public.decorate_items(id) ON DELETE SET NULL,
    card_skin_id UUID REFERENCES public.decorate_items(id) ON DELETE SET NULL,
    title_id UUID REFERENCES public.decorate_items(id) ON DELETE SET NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS Policies
ALTER TABLE public.decorate_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_equipped ENABLE ROW LEVEL SECURITY;

-- decorate_items: Everyone can read
CREATE POLICY "Enable read access for all users" ON public.decorate_items FOR SELECT USING (true);

-- user_items: Users can read their own items
CREATE POLICY "Users can view own items" ON public.user_items FOR SELECT USING (auth.uid() = user_id);
-- Insert policy might be needed for server-side logic or triggers, but for now assuming client doesn't directly insert

-- user_equipped: Users can read/update their own equipped items
CREATE POLICY "Users can view own equipped items" ON public.user_equipped FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own equipped items" ON public.user_equipped FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own equipped items" ON public.user_equipped FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Insert dummy data for testing
INSERT INTO public.decorate_items (type, name, asset_url, rarity, metadata) VALUES
('character', 'Neon Cyber Punk', 'assets/chars/cyber_punk.png', 'epic', '{"color": "#FF0099"}'),
('character', 'Space Marine', 'assets/chars/space_marine.png', 'rare', '{"color": "#00FFFF"}'),
('frame', 'Gold Border', 'assets/frames/gold.png', 'common', '{}'),
('card_skin', 'Pixel Art', 'assets/cards/pixel.png', 'rare', '{}'),
('title', 'Poker King', 'King', 'legendary', '{"color": "#FFD700"}')
ON CONFLICT DO NOTHING;
