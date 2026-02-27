#!/usr/bin/env node
/**
 * 🎯 HRC 30BB 프리플랍 GTO 데이터 파서 v2 (Ultra-Light)
 * 
 * 7,258개 HRC 노드 → 1개 master_30bb.json
 * 
 * 경량화 전략:
 *  1. 확률을 0~100 정수(%)로 변환 (소수점 제거)
 *  2. 100% Fold(기본값)인 핸드는 아예 저장하지 않음
 *  3. 0인 확률 키도 생략 (예: fold:0은 생략)
 *  4. 배열 포맷 [f, c, r, a] 사용 (키 이름 제거)
 *  5. hands 데이터 없는 리프 노드 스킵
 * 
 * 최종 구조:
 * {
 *   "meta": { "format": "[fold%, call%, raise%, allin%]", "positions": {...} },
 *   "nodes": {
 *     "UTG": { "AA": [0,0,99,1], "AKs": [0,53,47,0], ... },
 *     "UTG_F__UTG1": { ... },
 *   }
 * }
 * 
 * 실행: node tools/parse_hrc.js
 */

const fs = require('fs');
const path = require('path');

const NODES_DIR = path.join(__dirname, '..', 'assets', 'db', '30BB 옴니 스와이프', 'nodes');
const OUTPUT_FILE = path.join(__dirname, '..', 'assets', 'db', 'master_30bb.json');
const ALL_IN_AMOUNT = 600000;

const POSITION_MAP = {
    0: 'UTG', 1: 'UTG1', 2: 'UTG2', 3: 'LJ',
    4: 'HJ', 5: 'CO', 6: 'BTN', 7: 'SB', 8: 'BB',
};

// 액션 분류: 단축키
const ACTION_SHORT = { F: 'F', C: 'C' };
function classifyActionShort(type, amount) {
    if (type === 'F') return 'F';
    if (type === 'C') return 'C';
    if (type === 'R' && amount >= ALL_IN_AMOUNT) return 'A'; // All-in
    if (type === 'R') return 'R'; // Raise
    return type;
}

// 시나리오 키 생성 (축약)
function buildKey(sequence) {
    if (!sequence || sequence.length === 0) return '';
    return sequence.map(s => {
        const pos = POSITION_MAP[s.player] || `P${s.player}`;
        return `${pos}_${classifyActionShort(s.type, s.amount)}`;
    }).join('.');
}

function main() {
    console.log('🚀 HRC 30BB 파서 v2 (Ultra-Light) 시작...');

    const files = fs.readdirSync(NODES_DIR).filter(f => f.endsWith('.json'));
    console.log(`📄 파일 수: ${files.length}`);

    const nodes = {};
    let processed = 0, skipped = 0, handsDropped = 0, handsKept = 0;

    for (const file of files) {
        let node;
        try {
            node = JSON.parse(fs.readFileSync(path.join(NODES_DIR, file), 'utf-8'));
        } catch { skipped++; continue; }

        if (node.street !== 0 || !node.hands || Object.keys(node.hands).length === 0) {
            skipped++;
            continue;
        }

        const seqKey = buildKey(node.sequence);
        const actingPos = POSITION_MAP[node.player] || `P${node.player}`;
        const fullKey = seqKey ? `${seqKey}__${actingPos}` : actingPos;

        // 액션 라벨 배열
        const actionLabels = node.actions.map(a => classifyActionShort(a.type, a.amount));

        const handsData = {};
        for (const [hand, info] of Object.entries(node.hands)) {
            // 각 액션별 확률 합산
            const freqs = { F: 0, C: 0, R: 0, A: 0 };
            for (let i = 0; i < actionLabels.length; i++) {
                freqs[actionLabels[i]] = (freqs[actionLabels[i]] || 0) + (info.played[i] || 0);
            }

            // 퍼센트 정수 변환
            const fold = Math.round(freqs.F * 100);
            const call = Math.round(freqs.C * 100);
            const raise = Math.round(freqs.R * 100);
            const allin = Math.round(freqs.A * 100);

            // 100% Fold는 기본값이므로 저장 안 함 (용량 절약)
            if (fold === 100 && call === 0 && raise === 0 && allin === 0) {
                handsDropped++;
                continue;
            }

            // 배열 포맷: [fold, call, raise, allin]
            handsData[hand] = [fold, call, raise, allin];
            handsKept++;
        }

        // 모든 핸드가 100% Fold인 시나리오는 저장할 필요 없음
        if (Object.keys(handsData).length > 0) {
            nodes[fullKey] = handsData;
            processed++;
        }
    }

    // 메타데이터 포함
    const output = {
        meta: {
            version: '1.0',
            format: '[fold%, call%, raise%, allin%]',
            description: '30BB 9-max Preflop GTO frequencies. Hands with 100% fold are omitted.',
            positions: POSITION_MAP,
            totalScenarios: processed,
        },
        nodes,
    };

    const zlib = require('zlib');
    const jsonStr = JSON.stringify(output);
    const compressed = zlib.gzipSync(Buffer.from(jsonStr, 'utf-8'));

    const GZ_OUTPUT_FILE = OUTPUT_FILE + '.gz';
    fs.writeFileSync(GZ_OUTPUT_FILE, compressed);

    const sizeKB = (compressed.length / 1024).toFixed(1);
    const sizeMB = (compressed.length / 1024 / 1024).toFixed(2);

    console.log('\n✅ 압축 완료 (GZIP)!');
    console.log(`🎯 시나리오(키): ${processed}`);
    console.log(`📦 저장된 핸드 엔트리: ${handsKept.toLocaleString()}`);
    console.log(`🗑️  생략(100%Fold): ${handsDropped.toLocaleString()}`);
    console.log(`⏭️  스킵 노드: ${skipped}`);
    console.log(`📏 파일 크기: ${sizeKB} KB (${sizeMB} MB)`);
    console.log(`📁 출력: ${GZ_OUTPUT_FILE}`);

    // 샘플
    const sampleKeys = Object.keys(nodes).slice(0, 5);
    console.log('\n🔍 샘플:');
    for (const k of sampleKeys) {
        const hc = Object.keys(nodes[k]).length;
        const aa = nodes[k]['AA'];
        console.log(`  "${k}" (${hc} hands) AA:${JSON.stringify(aa)}`);
    }
}

main();
