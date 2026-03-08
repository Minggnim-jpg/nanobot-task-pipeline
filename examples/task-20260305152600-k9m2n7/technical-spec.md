# 扑克牌比较工具 - 技术方案

## 1. 技术选型

### 1.1 编程语言
- **Python 3.8+**: 项目指定语言，利用类型注解和现代 Python 特性

### 1.2 依赖库
- 标准库即可，无需额外依赖
- 使用 `enum` 模块定义牌型和花色枚举
- 使用 `dataclasses` 定义数据结构
- 使用 `typing` 模块进行类型注解

### 1.3 测试框架
- `pytest`: 项目标准测试框架
- `unittest`: 作为备选

## 2. 模块划分

### 2.1 整体架构

```
example-project/
└── src/
    └── poker/
        ├── __init__.py
        ├── card.py          # 牌的数据结构
        ├── hand.py          # 手牌分析
        ├── hand_ranker.py   # 牌型评级
        ├── comparator.py    # 牌型比较
        └── exceptions.py    # 自定义异常
```

### 2.2 模块职责

| 模块 | 职责 |
|------|------|
| `card.py` | 定义 Card 类，表示单张扑克牌 |
| `hand.py` | 定义 Hand 类，分析手牌组成 |
| `hand_ranker.py` | 牌型识别和评级逻辑 |
| `comparator.py` | 两手牌的比较逻辑 |
| `exceptions.py` | 定义 InvalidCardError, InvalidHandError 等异常 |

## 3. 数据结构

### 3.1 花色枚举

```python
from enum import Enum

class Suit(Enum):
    HEARTS = "H"      # 红桃
    DIAMONDS = "D"    # 方块
    CLUBS = "C"       # 梅花
    SPADES = "S"      # 黑桃
```

### 3.2 点数映射

```python
# 点数到数值的映射（用于比较）
RANK_VALUES = {
    "2": 2, "3": 3, "4": 4, "5": 5, "6": 6,
    "7": 7, "8": 8, "9": 9, "10": 10,
    "J": 11, "Q": 12, "K": 13, "A": 14
}

# 顺子特殊处理：A 可作为 1
STRAIGHT_RANKS = [14, 5, 4, 3, 2]  # A-2-3-4-5 特殊顺子
```

### 3.3 牌型枚举

```python
from enum import IntEnum

class HandType(IntEnum):
    HIGH_CARD = 1        # 高牌
    ONE_PAIR = 2         # 一对
    TWO_PAIR = 3         # 两对
    THREE_OF_A_KIND = 4  # 三条
    STRAIGHT = 5         # 顺子
    FLUSH = 6            # 同花
    FULL_HOUSE = 7       # 葫芦
    FOUR_OF_A_KIND = 8   # 四条
    STRAIGHT_FLUSH = 9   # 同花顺
    ROYAL_FLUSH = 10     # 皇家同花顺
```

### 3.4 Card 类

```python
from dataclasses import dataclass

@dataclass
class Card:
    rank: str           # 点数：2-9, 10, J, Q, K, A
    suit: Suit          # 花色
    value: int          # 数值（用于比较）
    
    @classmethod
    def from_string(cls, s: str) -> 'Card':
        """从字符串解析，如 'AH', '10D'"""
        pass
    
    def __str__(self) -> str:
        """返回标准字符串表示"""
        pass
```

### 3.5 HandAnalysis 类

```python
from dataclasses import dataclass
from typing import List

@dataclass
class HandAnalysis:
    hand_type: HandType      # 牌型
    tiebreakers: List[int]   # 决胜牌列表（按重要性排序）
    
    def __lt__(self, other: 'HandAnalysis') -> bool:
        """比较两个手牌分析结果"""
        pass
```

## 4. 算法设计

### 4.1 牌型识别流程

```
1. 解析输入字符串为 Card 对象列表
2. 统计各点数出现次数
3. 检查是否为同花（所有牌花色相同）
4. 检查是否为顺子（点数连续）
5. 根据点数频次分布判断牌型：
   - 4+1: 四条
   - 3+2: 葫芦
   - 3+1+1: 三条
   - 2+2+1: 两对
   - 2+1+1+1: 一对
   - 1+1+1+1+1: 高牌或顺子或同花
6. 组合判断：
   - 同花 + 顺子 = 同花顺（或皇家同花顺）
   - 同花 = 同花
   - 顺子 = 顺子
7. 生成 tiebreakers 列表用于平局比较
```

### 4.2 顺子检测算法

```python
def is_straight(ranks: List[int]) -> Tuple[bool, int]:
    """
    检查是否为顺子
    返回：(是否为顺子, 最大牌点数)
    
    特殊处理：A-2-3-4-5 顺子，最大牌为 5
    """
    sorted_ranks = sorted(ranks, reverse=True)
    
    # 检查普通顺子
    if all(sorted_ranks[i] - sorted_ranks[i+1] == 1 for i in range(4)):
        return True, sorted_ranks[0]
    
    # 检查 A-2-3-4-5 特殊顺子
    if sorted_ranks == [14, 5, 4, 3, 2]:
        return True, 5  # 最大牌为 5
    
    return False, 0
```

### 4.3 牌型比较算法

```python
def compare_hands(hand1: List[str], hand2: List[str]) -> int:
    """
    比较两手牌
    返回：1 (hand1 胜), -1 (hand2 胜), 0 (平局)
    """
    # 1. 解析并分析两手牌
    analysis1 = analyze_hand(hand1)
    analysis2 = analyze_hand(hand2)
    
    # 2. 比较牌型等级
    if analysis1.hand_type != analysis2.hand_type:
        return 1 if analysis1.hand_type > analysis2.hand_type else -1
    
    # 3. 牌型相同，比较 tiebreakers
    for t1, t2 in zip(analysis1.tiebreakers, analysis2.tiebreakers):
        if t1 != t2:
            return 1 if t1 > t2 else -1
    
    # 4. 完全相同，平局
    return 0
```

### 4.4 Tiebreakers 生成规则

| 牌型 | Tiebreakers 生成规则 |
|------|---------------------|
| 四条 | [四张牌的点数, 单牌点数] |
| 葫芦 | [三张牌的点数, 对子点数] |
| 同花/顺子/高牌 | [所有牌点数，从大到小] |
| 三条 | [三张牌的点数, 剩余牌从大到小] |
| 两对 | [大对子点数, 小对子点数, 单牌点数] |
| 一对 | [对子点数, 剩余牌从大到小] |

## 5. 测试策略

### 5.1 单元测试

#### 5.1.1 Card 类测试
```python
def test_card_from_string():
    assert Card.from_string("AH").rank == "A"
    assert Card.from_string("AH").suit == Suit.HEARTS
    assert Card.from_string("10D").rank == "10"
```

#### 5.1.2 牌型识别测试
```python
def test_royal_flush():
    hand = ["AH", "KH", "QH", "JH", "TH"]
    assert analyze_hand(hand).hand_type == HandType.ROYAL_FLUSH

def test_straight_wheel():
    hand = ["5H", "4D", "3C", "2S", "AH"]
    assert analyze_hand(hand).hand_type == HandType.STRAIGHT
```

#### 5.1.3 比较逻辑测试
```python
def test_hand_comparison():
    # 四条胜葫芦
    hand1 = ["AH", "AD", "AC", "AS", "2H"]
    hand2 = ["KH", "KD", "KS", "2H", "2D"]
    assert compare_hands(hand1, hand2) == 1

def test_tie():
    hand1 = ["AH", "KH", "QH", "JH", "TH"]
    hand2 = ["AD", "KD", "QD", "JD", "TD"]
    assert compare_hands(hand1, hand2) == 0
```

### 5.2 边界测试

- A 作为顺子最大（10-J-Q-K-A）
- A 作为顺子最小（A-2-3-4-5）
- 同点数不同花色的比较
- 所有可能的平局情况

### 5.3 输入验证测试

```python
def test_invalid_card_count():
    with pytest.raises(InvalidHandError):
        compare_hands(["AH", "KH"], ["AD", "KD", "QD", "JD", "TD"])

def test_duplicate_card():
    with pytest.raises(InvalidHandError):
        compare_hands(["AH", "AH", "QH", "JH", "TH"], ["AD", "KD", "QD", "JD", "TD"])

def test_invalid_card_format():
    with pytest.raises(InvalidCardError):
        compare_hands(["AH", "KH", "QH", "JH", "INVALID"], ["AD", "KD", "QD", "JD", "TD"])
```

### 5.4 测试覆盖率目标

- 语句覆盖率：≥ 95%
- 分支覆盖率：≥ 90%
- 所有牌型至少有一个测试用例

## 6. 文件输出位置

```
/path/to/workspace/projects/example-project/
├── src/
│   └── poker/
│       ├── __init__.py
│       ├── card.py
│       ├── hand.py
│       ├── hand_ranker.py
│       ├── comparator.py
│       └── exceptions.py
└── tests/
    └── test_poker/
        ├── __init__.py
        ├── test_card.py
        ├── test_hand_ranker.py
        └── test_comparator.py
```

## 7. 实现顺序建议

1. 定义基础数据结构（Card, Suit, HandType）
2. 实现牌型识别逻辑（hand_ranker.py）
3. 实现比较逻辑（comparator.py）
4. 编写单元测试
5. 代码审查和优化
