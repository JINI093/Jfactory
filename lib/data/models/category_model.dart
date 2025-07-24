class CategoryModel {
  final String title;
  final List<String> subcategories;

  CategoryModel({
    required this.title,
    required this.subcategories,
  });
}

class CategoryData {
  static final List<CategoryModel> categories = [
    CategoryModel(
      title: '절삭가공',
      subcategories: [
        '선반/밀링',
        '연마/연삭',
        '레이저 컷/와이어 컷/방전',
        '5축 가공기',
        '기타',
      ],
    ),
    CategoryModel(
      title: '절단/밴딩/절곡/용접',
      subcategories: [
        '절단',
        '밴딩',
        '절곡',
        '용접',
      ],
    ),
    CategoryModel(
      title: '사출',
      subcategories: [
        'PE',
        'PP',
        'PC',
        'ABS',
        '기타',
      ],
    ),
    CategoryModel(
      title: '금형',
      subcategories: [
        '프레스 금형',
        '몰드/포밍',
        '3D 프린터',
      ],
    ),
    CategoryModel(
      title: '표면처리',
      subcategories: [
        '도금(크롬/니켈 등)',
        '도장',
        '프라즈마(화염/대기압 등)',
      ],
    ),
    CategoryModel(
      title: '인쇄',
      subcategories: [
        '패드 인쇄',
        '실크(스크린) 인쇄',
        '핫스템핑',
        '그라비아/옵셋 인쇄',
        '필름(일러스트)',
      ],
    ),
    CategoryModel(
      title: '기계제작',
      subcategories: [
        '설계',
        '가공',
        '조립',
        '전기',
        '제어(PLC, PC 등)',
        '지그(JIG)',
        '프로파일',
        '제관',
        '주물',
      ],
    ),
    CategoryModel(
      title: '공구 MALL',
      subcategories: [
        '공구 MALL',
        '포장 MALL',
      ],
    ),
    CategoryModel(
      title: '볼트',
      subcategories: [
        '육각렌치',
        '둥근머리',
        '접시',
        '너트',
        '와샤',
      ],
    ),
    CategoryModel(
      title: '유공압',
      subcategories: [
        '실린더',
        '호스',
        '휘팅',
        '솔밸브',
        '커플러',
        '진공발생기',
      ],
    ),
    CategoryModel(
      title: '전기 자재',
      subcategories: [
        '전기자재',
      ],
    ),
    CategoryModel(
      title: 'Vision',
      subcategories: [
        '비전',
      ],
    ),
    CategoryModel(
      title: 'Motor',
      subcategories: [
        '모터',
      ],
    ),
  ];

  static List<List<CategoryModel>> get paginatedCategories {
    List<List<CategoryModel>> pages = [];
    for (int i = 0; i < categories.length; i += 8) {
      int end = (i + 8 < categories.length) ? i + 8 : categories.length;
      pages.add(categories.sublist(i, end));
    }
    return pages;
  }

  static CategoryModel? getCategoryByTitle(String title) {
    try {
      // Direct match first
      for (CategoryModel category in categories) {
        if (category.title == title) {
          return category;
        }
      }
      
      // Case-insensitive match as fallback
      for (CategoryModel category in categories) {
        if (category.title.toLowerCase() == title.toLowerCase()) {
          return category;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}