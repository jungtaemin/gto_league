// ============================================================================
// AllInFold Admin Panel — app.js (Redesigned)
// ============================================================================

// ─── Config ─────────────────────────────────────────────────────────────────
const SUPABASE_URL = 'https://lxhfosowckqzaryqgptu.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4aGZvc293Y2txemFyeXFncHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzNTI5MzksImV4cCI6MjA4NjkyODkzOX0.cb_OalSlbd2zvE1hK_622ActVhVcABssYGXcmm-KeIQ';

const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ─── State ──────────────────────────────────────────────────────────────────
let currentPage = 'send';
let historyPage = 0;
const HISTORY_PER_PAGE = 30;

// ─── Init ───────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
    setupEventListeners();
    sb.auth.onAuthStateChange(async (event, session) => {
        if (event === 'SIGNED_IN' && session) {
            await checkAdminAndShow(session);
        }
    });
    const { data: { session } } = await sb.auth.getSession();
    if (session) {
        await checkAdminAndShow(session);
    }
});

// ─── Event Listeners ────────────────────────────────────────────────────────
function setupEventListeners() {
    document.getElementById('login-form').addEventListener('submit', handleLogin);
    // Use click listener instead of form submit to prevent duplicate calls
    document.getElementById('send-btn').addEventListener('click', handleSend);

    document.querySelectorAll('input[name="target"]').forEach(radio => {
        radio.addEventListener('change', () => {
            const showUser = document.querySelector('input[name="target"]:checked').value === 'user';

            // Highlight active label
            document.querySelectorAll('input[name="target"]').forEach(r => {
                r.parentElement.classList.toggle('text-slate-400', !r.checked);
                r.parentElement.classList.toggle('text-white', r.checked);
            });

            document.getElementById('user-id-field').classList.toggle('hidden', !showUser);
        });
    });

    document.getElementById('user-search').addEventListener('keypress', e => {
        if (e.key === 'Enter') { e.preventDefault(); searchUsers(); }
    });
    document.getElementById('picker-search').addEventListener('keypress', e => {
        if (e.key === 'Enter') { e.preventDefault(); pickerSearch(); }
    });

    // Preview listeners
    ['send-title', 'send-body', 'send-type', 'send-chips', 'send-energy', 'send-expiry'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.addEventListener('input', updatePreview);
    });

    // Initial preview setup
    updatePreview();
}

// ─── Auth ────────────────────────────────────────────────────────────────────
async function handleLogin(e) {
    e.preventDefault();
    const email = document.getElementById('login-email').value.trim();
    const password = document.getElementById('login-password').value;
    const errorEl = document.getElementById('login-error');
    const btn = document.getElementById('login-btn');

    errorEl.classList.add('hidden');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner !border-t-slate-900 border-white/30 !w-5 !h-5 mr-2"></span> 접속 중...';

    try {
        const { data, error } = await sb.auth.signInWithPassword({ email, password });
        if (error) throw error;
        await checkAdminAndShow(data.session);
    } catch (err) {
        errorEl.textContent = err.message || '인증에 실패했습니다';
        errorEl.classList.remove('hidden');
    } finally {
        btn.disabled = false;
        btn.innerHTML = '시스템 로그인';
    }
}

async function loginWithGoogle() {
    const btn = document.getElementById('google-btn');
    btn.disabled = true;
    btn.innerHTML = '<div class="spinner !w-5 !h-5"></div>';
    try {
        const { error } = await sb.auth.signInWithOAuth({
            provider: 'google',
            options: { redirectTo: window.location.origin + window.location.pathname }
        });
        if (error) throw error;
    } catch (err) {
        toast(err.message || 'Google 로그인 실패', 'error');
        btn.disabled = false;
        btn.innerHTML = 'Google로 로그인';
    }
}

async function checkAdminAndShow(session) {
    try {
        const { data, error } = await sb.rpc('is_admin');
        if (error) throw error;
        if (!data) {
            toast('관리자 권한이 없습니다.', 'error');
            await sb.auth.signOut();
            return;
        }
    } catch (err) {
        console.error('checkAdmin error:', err);
        toast(`\uB85C\uADF8\uC778 \uC2E4\uD328`, 'error');
        await sb.auth.signOut();
        return;
    }

    document.getElementById('screen-login').classList.add('hidden');
    document.getElementById('screen-app').classList.remove('hidden');
    document.getElementById('user-email').textContent = session.user.email;
    navigate('send');
}

async function logout() {
    await sb.auth.signOut();
    document.getElementById('screen-app').classList.add('hidden');
    document.getElementById('screen-login').classList.remove('hidden');
    toast('안전하게 로그아웃 되었습니다', 'info');
}

// ─── Navigation ─────────────────────────────────────────────────────────────
function navigate(page) {
    currentPage = page;
    document.querySelectorAll('.page').forEach(p => p.classList.add('hidden'));
    const target = document.getElementById(`page-${page}`);
    if (target) target.classList.remove('hidden');

    document.querySelectorAll('.nav-btn').forEach(btn => {
        const isActive = btn.dataset.nav === page;
        btn.classList.toggle('bg-white/5', isActive);
        btn.classList.toggle('text-white', isActive);
        btn.classList.toggle('text-brand', isActive);

        // Icon color toggle inside the button
        const iconDiv = btn.querySelector('div');
        if (iconDiv) {
            iconDiv.classList.toggle('bg-brand/20', isActive);
            iconDiv.classList.toggle('bg-slate-800/50', !isActive);
            const svg = iconDiv.querySelector('svg');
            if (svg) svg.classList.toggle('text-brand', isActive);
        }
    });

    if (page === 'history') loadHistory();
    if (page === 'users') {
        const ulist = document.getElementById('users-list');
        if (ulist.children.length <= 1) searchUsers(); // load default if empty
    }
}

// ─── Send Mail ──────────────────────────────────────────────────────────────
function updatePreview() {
    const title = document.getElementById('send-title').value.trim() || '제목 표시 영역';
    const type = document.getElementById('send-type').value;
    const bodyRaw = document.getElementById('send-body').value.trim();
    const body = bodyRaw || '여기에 메일 본문 내용이 표시되어 보입니다. 유저 폰에서는 위아래로 스크롤 가능한 공간입니다.';
    const chips = parseInt(document.getElementById('send-chips').value) || 0;
    const energy = parseInt(document.getElementById('send-energy').value) || 0;
    const expiry = parseInt(document.getElementById('send-expiry').value) || null;

    const typeLabels = { system: '시스템', event: '이벤트', compensation: '보상', announcement: '공지' };
    const typeColors = {
        system: 'text-blue-400 font-bold',
        event: 'text-yellow-400 font-bold',
        compensation: 'text-red-400 font-bold',
        announcement: 'text-slate-400 font-bold',
    };

    let html = `
        <div class="flex items-center gap-3 mb-1">
            <span class="text-[10px] bg-slate-900 border border-slate-700 px-2 py-1 rounded-md ${typeColors[type]}">${typeLabels[type]}</span>
        </div>
        <div class="text-base font-black text-white leading-tight mb-3">
            ${escHtml(title)}
        </div>
    `;

    // Body box
    html += `
        <div class="bg-slate-900/50 rounded-lg p-3 border border-inset border-white/5 shadow-inner">
            <p class="text-xs text-slate-300 leading-relaxed whitespace-pre-wrap">${escHtml(body)}</p>
        </div>
    `;

    if (chips > 0 || energy > 0) {
        html += '<div class="mt-4 border-t border-dashed border-white/10 pt-3"><div class="text-[10px] text-slate-500 mb-2 uppercase tracking-wide">동봉된 보상</div><div class="flex gap-2">';
        if (chips > 0) html += `<div class="bg-yellow-500/10 border border-yellow-500/20 rounded px-3 py-1.5 flex items-center gap-1.5"><span class="text-sm">🪙</span><span class="text-xs font-bold text-yellow-500">${chips.toLocaleString()}</span></div>`;
        if (energy > 0) html += `<div class="bg-cyan-500/10 border border-cyan-500/20 rounded px-3 py-1.5 flex items-center gap-1.5"><span class="text-sm">⚡</span><span class="text-xs font-bold text-cyan-400">${energy}</span></div>`;
        html += '</div></div>';
    }

    if (expiry) {
        html += `<div class="text-[10px] text-slate-500 mt-4 text-center">⏰ ${expiry}일 후 만료</div>`;
    }

    const previewContainer = document.getElementById('send-preview');
    const contentBox = document.getElementById('preview-content');

    contentBox.innerHTML = html;
    previewContainer.classList.remove('opacity-50');
}

let _sendInProgress = false;
async function handleSend(e) {
    if (e) e.preventDefault();
    if (_sendInProgress) { console.warn('[handleSend] Already in progress, ignoring'); return; }
    _sendInProgress = true;

    const btn = document.getElementById('send-btn');
    const target = document.querySelector('input[name="target"]:checked').value;
    const type = document.getElementById('send-type').value;
    const title = document.getElementById('send-title').value.trim();
    const body = document.getElementById('send-body').value.trim();
    const chips = parseInt(document.getElementById('send-chips').value) || 0;
    const energy = parseInt(document.getElementById('send-energy').value) || 0;
    const expiryRaw = document.getElementById('send-expiry').value;
    const expiry = expiryRaw ? parseInt(expiryRaw) : null;

    console.log('[handleSend] target:', target, 'type:', type, 'title:', title, 'chips:', chips, 'energy:', energy, 'expiry:', expiry);

    if (!title) { toast('제목을 입력하세요', 'error'); _sendInProgress = false; return; }

    if (target === 'user') {
        const userId = document.getElementById('send-user-id').value.trim();
        if (!userId) { toast('대상을 선택하세요', 'error'); _sendInProgress = false; return; }
    }

    // Custom confirm modal (not native confirm())
    const targetLabel = target === 'all' ? '전체 유저' : '선택된 유저 1명';
    const confirmed = await showConfirmModal(
        '메일 발송 확인',
        `[${targetLabel}]에게 메일을 발송하시겠습니까?\n발송 후 회수할 수 없습니다.`
    );
    if (!confirmed) {
        _sendInProgress = false;
        return;
    }

    btn.disabled = true;
    btn.innerHTML = '<span class="spinner !border-t-brand border-white/30 mr-2"></span> 전송 중...';

    try {
        let result;
        if (target === 'all') {
            console.log('[handleSend] Calling admin_send_mail_to_all...');
            const { data, error } = await sb.rpc('admin_send_mail_to_all', { p_type: type, p_title: title, p_body: body, p_reward_chips: chips, p_reward_energy: energy, p_expires_in_days: expiry });
            console.log('[handleSend] Response:', { data, error });
            if (error) throw error;
            result = data;
        } else {
            const userId = document.getElementById('send-user-id').value.trim();
            console.log('[handleSend] Calling admin_send_mail for user:', userId);
            const { data, error } = await sb.rpc('admin_send_mail', { p_user_id: userId, p_type: type, p_title: title, p_body: body, p_reward_chips: chips, p_reward_energy: energy, p_expires_in_days: expiry });
            console.log('[handleSend] Response:', { data, error });
            if (error) throw error;
            result = data;
        }

        console.log('[handleSend] Result:', result);

        if (result && result.success) {
            const msg = target === 'all'
                ? `🚀 ${result.sent_count}명에게 발송 완료되었습니다!`
                : '🚀 발송이 완료되었습니다!';
            toast(msg, 'success');
            // Reset form
            document.getElementById('send-form').reset();
            document.getElementById('user-id-field').classList.add('hidden');
            document.getElementById('send-user-label').classList.add('hidden');
            document.querySelector('input[name="target"][value="all"]').dispatchEvent(new Event('change'));
            updatePreview();
        } else {
            const errMsg = result?.message || '발송 권한이 거부되었습니다';
            console.warn('[handleSend] Server rejected:', errMsg);
            toast(errMsg, 'error');
        }
    } catch (err) {
        console.error('[handleSend] Error:', err);
        toast(`API 오류: ${err?.message || String(err)}`, 'error');
    } finally {
        _sendInProgress = false;
        btn.disabled = false;
        btn.innerHTML = '<svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/></svg> 전송 승인';
    }
}

// ─── History ────────────────────────────────────────────────────────────────
async function loadHistory(page = 0) {
    historyPage = page;
    const tBody = document.getElementById('history-table-body');
    tBody.innerHTML = '<tr><td colspan="7" class="text-center py-20"><div class="spinner"></div><div class="text-sm text-slate-500 mt-3">요청 처리 중...</div></td></tr>';

    try {
        const { data, error } = await sb.rpc('admin_get_mail_history', { p_limit: HISTORY_PER_PAGE, p_offset: page * HISTORY_PER_PAGE });
        if (error) throw error;

        if (!data.mails || data.mails.length === 0) {
            tBody.innerHTML = '<tr><td colspan="7" class="text-center py-20 text-slate-500">조회된 발송 내역이 없습니다.</td></tr>';
            document.getElementById('history-pagination').innerHTML = '';
            return;
        }

        const typeLabels = { system: '시스템', event: '이벤트', compensation: '보상', announcement: '공지' };
        const typeBg = {
            system: 'bg-blue-400/10 text-blue-400 border border-blue-400/20',
            event: 'bg-yellow-400/10 text-yellow-400 border border-yellow-400/20',
            compensation: 'bg-red-400/10 text-red-400 border border-red-400/20',
            announcement: 'bg-slate-700 text-slate-300 border border-slate-600',
        };

        let html = '';

        for (const m of data.mails) {
            const reward = [];
            if (m.reward_chips > 0) reward.push(`<span class="font-mono text-yellow-400">${m.reward_chips.toLocaleString()}</span>🪙`);
            if (m.reward_energy > 0) reward.push(`<span class="font-mono text-cyan-400">${m.reward_energy}</span>⚡`);

            let status, statusClass;
            if (m.claimed_at) {
                status = '✅ 보상 획득'; statusClass = 'text-green-400 bg-green-400/10 border-green-400/20';
            } else if (m.is_read) {
                status = '👀 열람 (미수령)'; statusClass = 'text-slate-300 bg-slate-700/50 border-slate-600';
            } else {
                status = '📩 발송됨 (미열람)'; statusClass = 'text-cyan-400 bg-cyan-400/10 border-cyan-400/20';
            }

            const date = new Date(m.created_at).toLocaleString('ko-KR', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
            const userLabel = m.user_name || m.user_email || m.user_id?.substring(0, 12) + '...';

            html += `
                <tr class="hover:bg-slate-800/30 transition-colors group">
                    <td class="px-6 py-4">
                        <span class="text-[10px] font-bold px-2 py-1 rounded ${typeBg[m.type] || typeBg.system}">${typeLabels[m.type] || m.type}</span>
                    </td>
                    <td class="px-6 py-4">
                        <div class="max-w-[200px] truncate text-white font-medium" title="${escHtml(m.title)}">${escHtml(m.title)}</div>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex items-center gap-2">
                           <div class="w-6 h-6 rounded-full bg-slate-800 flex items-center justify-center text-[10px] text-slate-400 border border-slate-700 shrink-0">
                               ${m.user_email ? m.user_email[0].toUpperCase() : 'U'}
                           </div>
                           <span class="text-slate-300 text-xs truncate max-w-[120px] font-medium">${escHtml(userLabel)}</span>
                        </div>
                    </td>
                    <td class="px-6 py-4 text-xs font-semibold">
                        ${reward.length ? `<div class="flex gap-2 items-center">${reward.join('')}</div>` : '<span class="text-slate-600 font-normal">첨부 없음</span>'}
                    </td>
                    <td class="px-6 py-4">
                        <span class="text-[10px] font-medium border px-2 py-1 rounded-md ${statusClass}">${status}</span>
                    </td>
                    <td class="px-6 py-4 text-slate-500 font-mono text-xs">${date}</td>
                    <td class="px-6 py-4 text-center">
                        <button onclick="deleteMail('${m.id}')"
                                class="text-slate-600 hover:text-red-400 hover:bg-red-400/10 p-2 rounded-lg transition-all" title="기록 영구 삭제">
                            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>    
                        </button>
                    </td>
                </tr>`;
        }
        tBody.innerHTML = html;

        renderPagination(Math.ceil(data.total / HISTORY_PER_PAGE));
    } catch (err) {
        tBody.innerHTML = `<tr><td colspan="7" class="text-center py-20 text-red-400 bg-red-400/5 text-sm font-medium border border-dashed border-red-500/20 m-4 rounded-xl">${escHtml(err.message)}</td></tr>`;
    }
}

function renderPagination(totalPages) {
    const el = document.getElementById('history-pagination');
    if (totalPages <= 1) { el.innerHTML = ''; return; }

    let html = '';
    const btnClass = "min-w-[32px] h-8 rounded-lg text-xs font-medium transition-colors flex items-center justify-center border";

    if (historyPage > 0) {
        html += `<button onclick="loadHistory(${historyPage - 1})" class="${btnClass} bg-slate-800 text-slate-300 border-slate-700 hover:bg-slate-700 hover:text-white">&lt;</button>`;
    }

    for (let i = 0; i < totalPages; i++) {
        if (totalPages > 7 && Math.abs(i - historyPage) > 2 && i !== 0 && i !== totalPages - 1) {
            if (i === historyPage - 3 || i === historyPage + 3) html += '<span class="px-1 text-slate-600 grid place-items-center">…</span>';
            continue;
        }
        const active = i === historyPage
            ? 'bg-brand text-slate-900 border-brand shadow-glow'
            : 'bg-slate-800 text-slate-300 border-slate-700 hover:bg-slate-700 hover:text-white';
        html += `<button onclick="loadHistory(${i})" class="${btnClass} ${active}">${i + 1}</button>`;
    }

    if (historyPage < totalPages - 1) {
        html += `<button onclick="loadHistory(${historyPage + 1})" class="${btnClass} bg-slate-800 text-slate-300 border-slate-700 hover:bg-slate-700 hover:text-white">&gt;</button>`;
    }
    el.innerHTML = html;
}

async function deleteMail(id) {
    if (!confirm('이 기록을 DB에서 영구 삭제하시겠습니까?\n주의: 보상을 이미 획득한 기록도 지워집니다.')) return;

    try {
        const { data, error } = await sb.rpc('admin_delete_mail', { p_mail_id: id });
        if (error) throw error;
        if (data.success) {
            toast('기록이 파기되었습니다.', 'success');
            loadHistory(historyPage);
        } else {
            toast(data.message || '권한 부족', 'error');
        }
    } catch (err) {
        toast(`에러 발생: ${err.message}`, 'error');
    }
}

// ─── Users ──────────────────────────────────────────────────────────────────
async function searchUsers() {
    const query = document.getElementById('user-search').value.trim();
    const container = document.getElementById('users-list');
    container.innerHTML = '<div class="col-span-full text-center py-20"><div class="spinner border-t-brand"></div><div class="text-xs text-slate-500 mt-3">검색 중...</div></div>';
    console.log('[searchUsers] Starting search for:', query);

    try {
        const timeoutPromise = new Promise((_, reject) =>
            setTimeout(() => reject(new Error('서버 응답 시간 초과 (10초)')), 10000)
        );
        const rpcPromise = sb.rpc('admin_get_users', { p_search: query });
        const { data, error } = await Promise.race([rpcPromise, timeoutPromise]);

        console.log('[searchUsers] RPC response:', { data, error });

        if (error) throw error;

        if (!data || typeof data !== 'object') {
            container.innerHTML = '<div class="col-span-full glass-card rounded-2xl text-center py-20 text-slate-500 border border-dashed border-slate-700">서버 응답이 비어있습니다.</div>';
            return;
        }

        if (data.success === false) {
            container.innerHTML = `<div class="col-span-full glass-card rounded-2xl text-center py-20 text-red-400 border border-dashed border-red-500/20">${escHtml(data.message || '권한이 없습니다.')}</div>`;
            return;
        }

        const users = data.users;
        if (!users || !Array.isArray(users) || users.length === 0) {
            container.innerHTML = '<div class="col-span-full glass-card rounded-2xl text-center py-20 text-slate-500 border border-dashed border-slate-700">검색 조건에 맞는 유저가 없습니다.</div>';
            return;
        }

        console.log('[searchUsers] Found', users.length, 'users');

        container.innerHTML = users.map(u => {
            const name = u.display_name || '익명 유저';
            const initial = (u.email || '?')[0].toUpperCase();
            const joinDate = new Date(u.created_at).toLocaleDateString('ko-KR', { year: 'numeric', month: '2-digit', day: '2-digit' });

            return `
                <div class="glass-card rounded-2xl p-5 flex flex-col justify-between group">
                    <div class="flex items-start gap-4 mb-4">
                        ${u.avatar_url
                    ? `<img src="${escHtml(u.avatar_url)}" class="w-12 h-12 rounded-xl object-cover border border-white/10 shrink-0" onerror="this.outerHTML='<div class=\\'w-12 h-12 rounded-xl bg-gradient-to-br from-slate-700 to-slate-800 border border-white/5 flex items-center justify-center font-bold text-lg text-white shadow-inner shrink-0\\'>${initial}</div>'">`
                    : `<div class="w-12 h-12 rounded-xl bg-gradient-to-br from-slate-700 to-slate-800 border border-white/5 flex items-center justify-center font-bold text-lg text-white shadow-inner shrink-0">${initial}</div>`
                }
                        <div class="min-w-0 pr-2 pt-1 flex-1">
                            <div class="text-base font-bold text-white truncate group-hover:text-brand transition-colors">${escHtml(name)}</div>
                            <div class="text-[11px] text-slate-400 truncate mt-0.5">${escHtml(u.email)}</div>
                            <div class="text-[10px] text-slate-600 font-mono mt-1" title="User UUID">${u.id.substring(0, 8)}...</div>
                        </div>
                    </div>
                    
                    <div class="bg-slate-900/50 rounded-xl p-3 border border-white/5 flex items-center justify-between mb-4">
                        <div class="text-center px-2 border-r border-slate-700/50 flex-1">
                            <div class="text-[10px] text-slate-500 mb-1">가입일</div>
                            <div class="text-xs font-mono text-slate-300 whitespace-nowrap">${joinDate}</div>
                        </div>
                        <div class="text-center px-2 flex-1 relative">
                            <div class="text-[10px] text-slate-500 mb-1">우편 발송력</div>
                            <div class="text-xs font-bold text-cyan-400">${u.mail_count || 0}건</div>
                        </div>
                    </div>
                    
                    <button onclick="selectUserForMail('${u.id}', '${escHtml(u.email)}')" class="w-full btn-secondary text-xs h-10 py-0 flex items-center justify-center gap-2 group-hover:bg-slate-700">
                        <svg class="w-4 h-4 text-brand" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
                        다이렉트 메일 작성
                    </button>
                </div>`;
        }).join('');
    } catch (err) {
        console.error('[searchUsers] Error:', err);
        const errMsg = err?.message || String(err) || '알 수 없는 에러가 발생했습니다.';
        container.innerHTML = `<div class="col-span-full glass-card rounded-2xl text-center py-10 text-red-400 border border-red-500/20 bg-red-500/5 p-6">
            <div class="font-bold mb-1">⚠️ 검색 실패</div>
            <div>${escHtml(errMsg)}</div>
        </div>`;
    }
}

function selectUserForMail(userId, email) {
    document.getElementById('send-user-id').value = userId;
    const targetRadios = document.querySelectorAll('input[name="target"]');
    targetRadios.forEach(r => {
        r.checked = (r.value === 'user');
        r.dispatchEvent(new Event('change'));
    });

    document.getElementById('user-id-field').classList.remove('hidden');

    const label = document.getElementById('send-user-label');
    label.innerHTML = `선택된 타겟: <span class="text-white">${email}</span>`;
    label.classList.remove('hidden');

    navigate('send');
    toast(`타겟 설정 완료: ${email}`, 'success');
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// ─── Modal ──────────────────────────────────────────────────────────────────
function openUserPicker() {
    document.getElementById('user-picker-modal').classList.remove('hidden');
    document.getElementById('picker-search').value = '';
    document.getElementById('picker-results').innerHTML =
        '<div class="text-center py-12 text-slate-500 text-sm border border-dashed border-slate-700 rounded-xl">이름이나 이메일을 입력하세요.</div>';
    setTimeout(() => document.getElementById('picker-search').focus(), 100);
}

function closeUserPicker() {
    document.getElementById('user-picker-modal').classList.add('hidden');
}

async function pickerSearch() {
    const query = document.getElementById('picker-search').value.trim();
    const container = document.getElementById('picker-results');

    if (!query) {
        container.innerHTML = '<div class="text-center py-10 text-slate-500 text-sm border border-dashed border-slate-700 rounded-xl">어떤 유저를 찾을까요?</div>';
        return;
    }

    container.innerHTML = '<div class="text-center py-10"><div class="spinner"></div><div class="text-xs text-slate-500 mt-3">검색 중...</div></div>';
    console.log('[pickerSearch] Starting search for:', query);

    try {
        // Add 10 second timeout
        const timeoutPromise = new Promise((_, reject) =>
            setTimeout(() => reject(new Error('서버 응답 시간 초과 (10초)')), 10000)
        );

        const rpcPromise = sb.rpc('admin_get_users', { p_search: query });
        const { data, error } = await Promise.race([rpcPromise, timeoutPromise]);

        console.log('[pickerSearch] RPC response:', { data, error });

        if (error) throw error;

        // Handle case where data is null/undefined or not an object
        if (!data || typeof data !== 'object') {
            console.warn('[pickerSearch] Unexpected data format:', data);
            container.innerHTML = '<div class="text-center py-10 text-slate-500 text-sm border border-dashed border-slate-700 rounded-xl bg-slate-800/20">서버 응답이 비어있습니다.</div>';
            return;
        }

        // Handle unauthorized
        if (data.success === false) {
            container.innerHTML = `<div class="text-center py-10 text-red-400 text-sm border border-dashed border-red-500/20 rounded-xl bg-red-500/5">${escHtml(data.message || '권한이 없습니다.')}</div>`;
            return;
        }

        const users = data.users;
        if (!users || !Array.isArray(users) || users.length === 0) {
            container.innerHTML = '<div class="text-center py-10 text-slate-500 text-sm border border-dashed border-slate-700 rounded-xl bg-slate-800/20">조회된 정보가 없습니다.</div>';
            return;
        }

        console.log('[pickerSearch] Found', users.length, 'users');

        container.innerHTML = users.map(u => {
            const name = u.display_name || '이름 미설정';
            const initial = (u.email || '?')[0].toUpperCase();
            return `
                <button onclick="pickUser('${u.id}', '${escHtml(u.email)}')"
                        class="w-full text-left p-3 rounded-xl hover:bg-slate-800/80 active:bg-slate-800 flex items-center gap-4 transition group border border-transparent hover:border-white/5">
                    ${u.avatar_url
                    ? `<img src="${escHtml(u.avatar_url)}" class="w-10 h-10 rounded-lg object-cover">`
                    : `<div class="w-10 h-10 rounded-lg bg-slate-700 flex items-center justify-center font-bold text-white shadow-inner">${initial}</div>`
                }
                    <div class="min-w-0 flex-1">
                        <div class="text-sm font-bold text-white group-hover:text-brand transition-colors truncate">${escHtml(name)}</div>
                        <div class="text-xs text-slate-400 truncate">${escHtml(u.email)}</div>
                    </div>
                </button>`;
        }).join('');
    } catch (err) {
        console.error('[pickerSearch] Error:', err);
        const errMsg = err?.message || String(err) || '알 수 없는 에러가 발생했습니다.';
        container.innerHTML = `<div class="text-center py-4 text-red-400 text-sm bg-red-500/10 rounded-xl border border-red-500/20 p-4">
            <div class="font-bold mb-1">⚠️ 검색 실패</div>
            <div>${escHtml(errMsg)}</div>
        </div>`;
    }
}

function pickUser(userId, email) {
    document.getElementById('send-user-id').value = userId;
    const label = document.getElementById('send-user-label');
    label.innerHTML = `선택된 타겟: <span class="text-white">${email}</span>`;
    label.classList.remove('hidden');
    closeUserPicker();
}

// Global dismissals
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        const modal = document.getElementById('user-picker-modal');
        if (!modal.classList.contains('hidden')) closeUserPicker();
    }
});

// ─── Toast ──────────────────────────────────────────────────────────────────
function toast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    const colors = {
        success: 'bg-green-950/90 border-green-500/30 text-green-200 shadow-lg shadow-green-900/20',
        error: 'bg-red-950/90 border-red-500/30 text-red-200 shadow-lg shadow-red-900/20',
        info: 'glass-card border-brand/30 text-white shadow-glow',
    };
    const icons = { success: 'bg-green-500', error: 'bg-red-500', info: 'bg-brand' };

    const el = document.createElement('div');
    el.className = `${colors[type] || colors.info} border px-4 py-3.5 rounded-xl text-sm toast-enter flex items-center gap-3 backdrop-blur-xl relative overflow-hidden`;

    // Status dot
    el.innerHTML = `
        <div class="w-2 h-2 rounded-full ${icons[type]} shrink-0 shadow-[0_0_8px_currentColor]"></div>
        <span class="font-medium tracking-wide">${escHtml(message)}</span>
    `;
    container.appendChild(el);

    setTimeout(() => {
        el.classList.remove('toast-enter');
        el.classList.add('toast-exit');
        setTimeout(() => el.remove(), 400); // Wait for exit animation
    }, 4000);
}

function escHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

window.navigate = navigate;
window.logout = logout;
window.loginWithGoogle = loginWithGoogle;
window.searchUsers = searchUsers;
window.openUserPicker = openUserPicker;
window.closeUserPicker = closeUserPicker;
window.pickerSearch = pickerSearch;
window.pickUser = pickUser;
window.selectUserForMail = selectUserForMail;
window.loadHistory = loadHistory;
window.deleteMail = deleteMail;

// ─── Custom Confirm Modal ───────────────────────────────────────────────────
function showConfirmModal(title, message) {
    return new Promise((resolve) => {
        const modal = document.getElementById('confirm-modal');
        const titleEl = document.getElementById('confirm-title');
        const messageEl = document.getElementById('confirm-message');
        const okBtn = document.getElementById('confirm-ok-btn');
        const cancelBtn = document.getElementById('confirm-cancel-btn');

        titleEl.textContent = title;
        messageEl.textContent = message;
        modal.classList.remove('hidden');

        // Clone buttons to remove any existing listeners
        const newOk = okBtn.cloneNode(true);
        const newCancel = cancelBtn.cloneNode(true);
        okBtn.parentNode.replaceChild(newOk, okBtn);
        cancelBtn.parentNode.replaceChild(newCancel, cancelBtn);

        newOk.addEventListener('click', () => {
            modal.classList.add('hidden');
            resolve(true);
        });
        newCancel.addEventListener('click', () => {
            modal.classList.add('hidden');
            resolve(false);
        });
    });
}
