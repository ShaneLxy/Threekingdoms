import fs from "node:fs/promises";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = "E:/AIGame/ThreeKingdom/tests";
const workbook = Workbook.create();
const sheet = workbook.worksheets.add("TapTap新手文档");
const checklist = workbook.worksheets.add("发布清单");

const articles = [
  {
    no: 1,
    title: "新手入门：三分钟了解基础操作",
    category: "基础机制",
    audience: "首次进入游戏的玩家",
    body: `欢迎来到《三国：破阵无双》。这是一款横版动作割草游戏，战斗的核心不是站在原地连续攻击，而是边移动、边观察敌人预警、边选择合适的攻击和防御时机。\n\n基础操作：左侧摇杆负责移动和调整攻击方向；普攻按钮用于连段；技能按钮用于主动攻击或位移；格挡按钮用于短时间防御；无双按钮在能量充满后释放强力招式。\n\n新手建议先熟悉“移动 → 普攻 → 走位”的循环，再练习格挡。遇到精英或领主时，不要只看血条，也要观察攻击预警和出招动作。\n\n每次升级都会出现强化选择。通用强化适合补足基础属性，武将战法会改变当前武将的玩法，天机阵法则会在战场上自动提供支援。`,
    image: "建议配图：战斗界面标注操作区域",
  },
  {
    no: 2,
    title: "格挡怎么用？从预警到反击的完整教学",
    category: "重点机制",
    audience: "想提高生存能力的玩家",
    body: `格挡不是无敌，而是一段有方向限制的短时间防御。按下格挡后，角色会进入防御状态，主要防御来自正面的可防御攻击。背后和侧后方并不是完全安全的。\n\n最适合格挡的情况包括：近战敌人的突刺或斩击、正面飞来的箭矢和弩箭、精英武将的可拼刀招式，以及走位空间暂时被封锁时的紧急防御。\n\n正确流程是：先观察攻击预警或敌人的起手动作，转向攻击来源，再按下格挡。格挡结束后，不要继续站在原地，可以向侧面移动、接普攻、使用技能，或者重新拉开距离。\n\n常见误区：看到红圈就按格挡；格挡时频繁改变方向；格挡成功后贪刀。大范围攻击、持续伤害区域、背后攻击和部分特殊招式，应优先通过走位或技能躲避。\n\n练习方法：先不追求输出，只练习“观察预警 → 面向敌人 → 格挡 → 向侧面移动”。熟悉之后，再加入普攻和技能。`,
    image: "建议配图：格挡正面扇区与敌人攻击预警",
  },
  {
    no: 3,
    title: "局内升级怎么选？通用强化、战法与天机说明",
    category: "成长系统",
    audience: "不清楚升级选择的玩家",
    body: `局内强化主要分为三类：通用强化、武将战法和天机阵法。\n\n通用强化对所有武将都有效，例如攻击、防御、移动速度和战地回复，适合在构筑还没有成型时稳定提升基础能力。\n\n武将战法只强化当前武将。它们可能提高普攻范围、技能伤害、位移距离，也可能解锁新的连段或特殊效果。部分战法可以重复获得，但都有叠加上限；部分战法是一次性解锁，并且需要满足前置条件。\n\n天机阵法需要先在局外解锁，进入战斗后再通过升级选择启用。启用后，阵法会自动锁定目标并施放效果。天机强化可以提高伤害、范围、持续时间或降低冷却，但同样有叠加上限。\n\n选择思路：如果当前经常被击败，优先选择防御、护体、格挡或位移相关强化；如果已经能稳定生存，再围绕武将的核心机制集中选择，不要平均分散到所有路线。`,
    image: "建议配图：三选一升级卡示例",
  },
  {
    no: 4,
    title: "赵云玩法：如何利用龙胆和突进",
    category: "英雄玩法",
    audience: "赵云玩家",
    body: `赵云是高机动突进型武将，主要依靠持续移动、连续普攻、主动突进和龙胆状态作战。\n\n龙胆通过击杀普通敌军、命中精英和领主积累进度。达到触发条件后，赵云会获得护体和移速提升，龙胆最多叠加 3 层。每次增加层数都会刷新持续时间。\n\n赵云的普攻第三段适合穿过敌阵，主动技能适合快速切入、穿阵或脱离。面对密集敌军时，可以先把敌人聚成一条路线，再用突进技能穿过；不要长时间停在敌群中央。\n\n推荐强化方向：枪法强化提高普攻距离和横扫能力；龙胆强化提高触发频率、持续时间和移速；破军强化提高主动技能的伤害、范围和脱离能力。\n\n新手重点：赵云不是站桩输出角色。保持移动，利用突进改变位置，龙胆激活后再主动进入高密度敌群。`,
    image: "建议配图：龙胆状态和第三段突进演示",
  },
  {
    no: 5,
    title: "关羽玩法：格挡、击退和兵势",
    category: "英雄玩法",
    audience: "关羽玩家",
    body: `关羽是重型近战与破势型武将。基础移动速度较低，但拥有大范围偃月攻击、击退、格挡和强力刀浪。\n\n关羽的核心不是一直绕圈跑，而是通过攻击范围和击退控制敌人的距离。面对近战攻击或正面箭矢时，可以用格挡度过危险瞬间；敌人聚集后，用普攻和青龙断浪清理阵型。\n\n兵势会根据附近敌人数量提供攻防收益，因此关羽可以适度进入敌群作战，但不要在没有技能或格挡时长时间停留。受到包围时，优先用青龙断浪、拖刀或后续位移拉开空间。\n\n推荐强化方向：偃月强化普攻范围；断浪强化刀浪距离、宽度和击退；武圣强化无双期间的持续作战能力。\n\n新手重点：关羽的低移速是角色定位的一部分。先用范围和击退控制战场，再输出，不要把关羽当作高速风筝型武将。`,
    image: "建议配图：关羽普攻范围、格挡和青龙断浪",
  },
  {
    no: 6,
    title: "张飞玩法：怒势、跃砸和万夫莫开",
    category: "英雄玩法",
    audience: "张飞玩家",
    body: `张飞是控制、击退与重击型武将。基础移动速度较低，但拥有较高的生命和防御，以及跃砸、击退和怒势强化。\n\n怒势通过击杀和格挡积累。进入怒势后，张飞的攻击速度、侧后方生存能力和飞兵碰撞效果都会提升。尽量在敌人较密集时积累和维持怒势。\n\n丈八跃砸适合打断敌军阵型，也可以用来改变自己的位置。据水断桥可以短按快速跃砸，长按蓄力后控制跳跃距离。被包围时，优先选择安全落点，而不是盲目跳进最密集的位置。\n\n推荐强化方向：怒势强化触发速度和持续时间；断桥强化跃砸范围、伤害和击退；无双强化万夫莫开期间的减伤和持续战斗能力。\n\n新手重点：张飞不是靠高速移动躲开所有攻击，而是靠击退、减伤和跃砸改变战场位置。提前规划落点，比频繁小范围折返更重要。`,
    image: "建议配图：怒势层数、跃砸落点和万夫状态",
  },
  {
    no: 7,
    title: "常见问题与版本说明",
    category: "FAQ",
    audience: "所有玩家",
    body: `问：格挡能挡住所有攻击吗？\n答：不能。格挡主要防御角色正面的可防御攻击。大范围攻击、持续伤害、背后攻击和部分特殊技能，需要通过走位或技能规避。\n\n问：通用强化可以无限叠加吗？\n答：不能。通用强化都有叠加上限，达到上限后不会继续出现。\n\n问：天机技能的冷却强化有效吗？\n答：有效。天机的冷却强化会降低实际冷却时间，但仍受到最低冷却限制。\n\n问：移速低的武将是不是比较弱？\n答：不是。关羽和张飞属于重型武将，主要通过击退、格挡、跃砸、减伤和范围攻击生存。\n\n问：为什么有时普攻打不到上下方的敌人？\n答：不同武将的普攻方向和判定范围不同。部分武将的普通状态更偏向左右攻击，建议通过移动调整站位，或使用技能处理侧面和上下方敌人。\n\n本文内容以当前版本为准。部分数值和技能表现可能根据实战反馈调整，欢迎在评论区分享使用体验。`,
    image: "建议配图：版本号或问题反馈入口",
  },
];

sheet.showGridLines = false;
sheet.mergeCells("A1:G1");
sheet.getRange("A1").values = [["《三国：破阵无双》TapTap 新手文档草稿"]];
sheet.getRange("A2:G2").merge();
sheet.getRange("A2").values = [["用途：逐篇复制到 TapTap 社区发布。当前仅包含已发布的赵云、关羽、张飞，不包含马超和黄忠。"]];
sheet.getRange("A4:G4").values = [["序号", "文章标题", "分类", "适合读者", "TapTap 正文", "配图建议", "发布备注"]];
const rows = articles.map((a) => [a.no, a.title, a.category, a.audience, a.body, a.image, "待发布"]);
sheet.getRange(`A5:G${4 + rows.length}`).values = rows;
sheet.getRange("A1:G1").format = { fill: "#203A43", font: { bold: true, color: "#FFFFFF", size: 16 }, horizontalAlignment: "center", verticalAlignment: "center" };
sheet.getRange("A2:G2").format = { fill: "#EAF2F3", font: { color: "#38525A", italic: true }, wrapText: true, verticalAlignment: "center" };
sheet.getRange("A4:G4").format = { fill: "#2D6A73", font: { bold: true, color: "#FFFFFF" }, horizontalAlignment: "center", verticalAlignment: "center", wrapText: true };
sheet.getRange(`A5:G${4 + rows.length}`).format = { verticalAlignment: "top", wrapText: true, font: { color: "#203238", size: 11 } };
sheet.getRange(`A5:A${4 + rows.length}`).format.horizontalAlignment = "center";
sheet.getRange(`G5:G${4 + rows.length}`).format.horizontalAlignment = "center";
sheet.getRange(`A4:G${4 + rows.length}`).format.borders = { insideHorizontal: { style: "thin", color: "#D7E1E3" }, outside: { style: "medium", color: "#7C9CA3" } };
sheet.getRange("A:A").format.columnWidth = 8;
sheet.getRange("B:B").format.columnWidth = 31;
sheet.getRange("C:C").format.columnWidth = 14;
sheet.getRange("D:D").format.columnWidth = 23;
sheet.getRange("E:E").format.columnWidth = 88;
sheet.getRange("F:F").format.columnWidth = 34;
sheet.getRange("G:G").format.columnWidth = 14;
sheet.getRange("A1:G1").format.rowHeight = 30;
sheet.getRange("A2:G2").format.rowHeight = 32;
sheet.getRange("A4:G4").format.rowHeight = 28;
for (let r = 5; r <= 4 + rows.length; r++) sheet.getRange(`A${r}:G${r}`).format.rowHeight = 205;
sheet.freezePanes.freezeRows(4);

checklist.showGridLines = false;
checklist.mergeCells("A1:F1");
checklist.getRange("A1").values = [["TapTap 发布清单"]];
checklist.getRange("A3:F3").values = [["序号", "文章标题", "建议发布时间", "配图是否完成", "是否发布", "备注"]];
checklist.getRange("A4:F10").values = articles.map((a) => [a.no, a.title, "", "未完成", "待发布", ""]);
checklist.getRange("A1:F1").format = { fill: "#203A43", font: { bold: true, color: "#FFFFFF", size: 16 }, horizontalAlignment: "center", verticalAlignment: "center" };
checklist.getRange("A3:F3").format = { fill: "#2D6A73", font: { bold: true, color: "#FFFFFF" }, horizontalAlignment: "center", verticalAlignment: "center", wrapText: true };
checklist.getRange("A4:F10").format = { verticalAlignment: "center", wrapText: true, font: { color: "#203238", size: 11 } };
checklist.getRange("A4:A10").format.horizontalAlignment = "center";
checklist.getRange("D4:E10").dataValidation = { rule: { type: "list", values: ["未完成", "已完成"] } };
checklist.getRange("A3:F10").format.borders = { insideHorizontal: { style: "thin", color: "#D7E1E3" }, outside: { style: "medium", color: "#7C9CA3" } };
checklist.getRange("A:A").format.columnWidth = 8;
checklist.getRange("B:B").format.columnWidth = 42;
checklist.getRange("C:C").format.columnWidth = 20;
checklist.getRange("D:E").format.columnWidth = 18;
checklist.getRange("F:F").format.columnWidth = 36;
checklist.getRange("A1:F1").format.rowHeight = 30;
checklist.getRange("A3:F3").format.rowHeight = 28;
checklist.getRange("A4:F10").format.rowHeight = 28;
checklist.freezePanes.freezeRows(3);

const preview1 = await workbook.render({ sheetName: "TapTap新手文档", range: "A1:G11", scale: 1, format: "png" });
await fs.writeFile(`${outputDir}/taptap_newbie_docs_preview.png`, new Uint8Array(await preview1.arrayBuffer()));
const preview2 = await workbook.render({ sheetName: "发布清单", range: "A1:F10", scale: 1, format: "png" });
await fs.writeFile(`${outputDir}/taptap_publish_checklist_preview.png`, new Uint8Array(await preview2.arrayBuffer()));
const xlsx = await SpreadsheetFile.exportXlsx(workbook);
await xlsx.save(`${outputDir}/taptap_newbie_docs.xlsx`);
const check = await workbook.inspect({ kind: "table", range: "TapTap新手文档!A1:G11", include: "values,formulas", tableMaxRows: 12, tableMaxCols: 8 });
console.log(check.ndjson);
const errors = await workbook.inspect({ kind: "match", searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A", options: { useRegex: true, maxResults: 50 }, summary: "formula error scan" });
console.log(errors.ndjson);
