-- ═══════════════════════════════════════════════════════════════
-- Admin Mail Functions (All 5 RPC endpoints)
-- ═══════════════════════════════════════════════════════════════

-- 1. admin_get_users: Search users by email, name, or UUID
CREATE OR REPLACE FUNCTION public.admin_get_users(p_search text DEFAULT ''::text, p_limit integer DEFAULT 20)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
SET statement_timeout TO '5s'
AS $function$
DECLARE
  v_result JSONB;
BEGIN
  IF NOT is_admin() THEN
    RETURN jsonb_build_object('success', false, 'message', 'Unauthorized');
  END IF;

  SELECT COALESCE(jsonb_agg(row_to_json(t)), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT
      u.id, u.email,
      u.raw_user_meta_data->>'full_name' AS display_name,
      u.raw_user_meta_data->>'avatar_url' AS avatar_url,
      u.created_at, u.last_sign_in_at,
      (SELECT COUNT(*) FROM public.user_mail WHERE user_id = u.id) AS mail_count
    FROM auth.users u
    WHERE p_search = ''
      OR u.id::text = p_search
      OR u.email ILIKE '%' || p_search || '%'
      OR u.raw_user_meta_data->>'full_name' ILIKE '%' || p_search || '%'
    ORDER BY u.created_at DESC
    LIMIT p_limit
  ) t;

  RETURN jsonb_build_object('success', true, 'users', v_result);
END;
$function$;

-- 2. admin_send_mail: Send mail to a specific user
CREATE OR REPLACE FUNCTION public.admin_send_mail(p_user_id uuid, p_type text, p_title text, p_body text DEFAULT ''::text, p_reward_chips integer DEFAULT 0, p_reward_energy integer DEFAULT 0, p_expires_in_days integer DEFAULT NULL::integer)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_expires_at TIMESTAMPTZ;
  v_mail_id UUID;
BEGIN
  IF NOT is_admin() THEN
    RETURN jsonb_build_object('success', false, 'message', 'Unauthorized: admin access required');
  END IF;

  IF p_expires_in_days IS NOT NULL THEN
    v_expires_at := timezone('utc'::text, now()) + (p_expires_in_days || ' days')::INTERVAL;
  END IF;

  INSERT INTO public.user_mail (user_id, type, title, body, reward_chips, reward_energy, expires_at)
  VALUES (p_user_id, p_type, p_title, p_body, p_reward_chips, p_reward_energy, v_expires_at)
  RETURNING id INTO v_mail_id;

  RETURN jsonb_build_object(
    'success', true,
    'mail_id', v_mail_id,
    'message', 'Mail sent successfully'
  );
END;
$function$;

-- 3. admin_send_mail_to_all: Send mail to all users
CREATE OR REPLACE FUNCTION public.admin_send_mail_to_all(p_type text, p_title text, p_body text DEFAULT ''::text, p_reward_chips integer DEFAULT 0, p_reward_energy integer DEFAULT 0, p_expires_in_days integer DEFAULT NULL::integer)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_expires_at TIMESTAMPTZ;
  v_sent_count INTEGER;
BEGIN
  IF NOT is_admin() THEN
    RETURN jsonb_build_object('success', false, 'message', 'Unauthorized: admin access required');
  END IF;

  IF p_expires_in_days IS NOT NULL THEN
    v_expires_at := timezone('utc'::text, now()) + (p_expires_in_days || ' days')::INTERVAL;
  END IF;

  INSERT INTO public.user_mail (user_id, type, title, body, reward_chips, reward_energy, expires_at)
  SELECT id, p_type, p_title, p_body, p_reward_chips, p_reward_energy, v_expires_at
  FROM auth.users;

  GET DIAGNOSTICS v_sent_count = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'sent_count', v_sent_count,
    'message', format('Mail sent to %s users', v_sent_count)
  );
END;
$function$;

-- 4. admin_get_mail_history: Get mail history with pagination
CREATE OR REPLACE FUNCTION public.admin_get_mail_history(p_limit integer DEFAULT 50, p_offset integer DEFAULT 0)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_result JSONB;
  v_total INTEGER;
BEGIN
  IF NOT is_admin() THEN
    RETURN jsonb_build_object('success', false, 'message', 'Unauthorized');
  END IF;

  SELECT COUNT(*) INTO v_total FROM public.user_mail;

  SELECT COALESCE(jsonb_agg(row_to_json(t)), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT
      m.id, m.user_id, u.email AS user_email,
      u.raw_user_meta_data->>'full_name' AS user_name,
      m.type, m.title, m.body, m.reward_chips, m.reward_energy,
      m.is_read, m.claimed_at, m.created_at, m.expires_at
    FROM public.user_mail m
    LEFT JOIN auth.users u ON m.user_id = u.id
    ORDER BY m.created_at DESC
    LIMIT p_limit OFFSET p_offset
  ) t;

  RETURN jsonb_build_object('success', true, 'total', v_total, 'mails', v_result);
END;
$function$;

-- 5. admin_delete_mail: Delete a specific mail
CREATE OR REPLACE FUNCTION public.admin_delete_mail(p_mail_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  IF NOT is_admin() THEN
    RETURN jsonb_build_object('success', false, 'message', 'Unauthorized');
  END IF;

  DELETE FROM public.user_mail WHERE id = p_mail_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Mail not found');
  END IF;

  RETURN jsonb_build_object('success', true, 'deleted_id', p_mail_id);
END;
$function$;