import '../../domain/entities/region_entity.dart';

class RegionModel {
  final String title;
  final List<String> districts;

  RegionModel({
    required this.title,
    required this.districts,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      title: json['title'] as String,
      districts: List<String>.from(json['districts'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'districts': districts,
    };
  }

  RegionEntity toEntity() {
    return RegionEntity(
      id: title,
      name: title,
      level: 0, // 시/도 레벨
    );
  }

  factory RegionModel.fromEntity(RegionEntity entity) {
    return RegionModel(
      title: entity.name,
      districts: [], // districts는 별도로 관리
    );
  }
}

class RegionData {
  static final List<RegionModel> regions = [
    RegionModel(
      title: '서울특별시',
      districts: [
        '강남구', '서초구', '송파구', '강동구', '영등포구', '구로구', '금천구', 
        '동작구', '관악구', '성동구', '광진구', '중랑구', '성북구', '강북구', 
        '도봉구', '노원구', '은평구', '서대문구', '마포구', '양천구', '강서구', 
        '종로구', '중구', '용산구'
      ],
    ),
    RegionModel(
      title: '경기도',
      districts: [
        '수원시', '성남시', '안양시', '안산시', '과천시', '광명시', '구리시', 
        '남양주시', '오산시', '시흥시', '군포시', '의왕시', '하남시', '용인시', 
        '파주시', '이천시', '안성시', '김포시', '화성시', '광주시', '양주시', 
        '포천시', '여주시', '연천군', '가평군', '양평군'
      ],
    ),
    RegionModel(
      title: '부산광역시',
      districts: [
        '중구', '서구', '동구', '영도구', '부산진구', '동래구', '남구', 
        '북구', '해운대구', '사하구', '금정구', '강서구', '연제구', 
        '수영구', '사상구', '기장군'
      ],
    ),
    RegionModel(
      title: '대구광역시',
      districts: [
        '중구', '동구', '서구', '남구', '북구', '수성구', '달서구', '달성군'
      ],
    ),
    RegionModel(
      title: '인천광역시',
      districts: [
        '중구', '동구', '미추홀구', '연수구', '남동구', '부평구', 
        '계양구', '서구', '강화군', '옹진군'
      ],
    ),
    RegionModel(
      title: '광주광역시',
      districts: [
        '동구', '서구', '남구', '북구', '광산구'
      ],
    ),
    RegionModel(
      title: '대전광역시',
      districts: [
        '동구', '중구', '서구', '유성구', '대덕구'
      ],
    ),
    RegionModel(
      title: '울산광역시',
      districts: [
        '중구', '남구', '동구', '북구', '울주군'
      ],
    ),
    RegionModel(
      title: '강원도',
      districts: [
        '춘천시', '원주시', '강릉시', '동해시', '태백시', '속초시', 
        '삼척시', '홍천군', '횡성군', '영월군', '평창군', '정선군', 
        '철원군', '화천군', '양구군', '인제군', '고성군', '양양군'
      ],
    ),
    RegionModel(
      title: '충청북도',
      districts: [
        '청주시', '충주시', '제천시', '보은군', '옥천군', '영동군', 
        '진천군', '괴산군', '음성군', '단양군', '증평군'
      ],
    ),
    RegionModel(
      title: '충청남도',
      districts: [
        '천안시', '공주시', '보령시', '아산시', '서산시', '논산시', 
        '계룡시', '당진시', '금산군', '부여군', '서천군', '청양군', 
        '홍성군', '예산군', '태안군'
      ],
    ),
    RegionModel(
      title: '전라북도',
      districts: [
        '전주시', '군산시', '익산시', '정읍시', '남원시', '김제시', 
        '완주군', '진안군', '무주군', '장수군', '임실군', '순창군', 
        '고창군', '부안군'
      ],
    ),
    RegionModel(
      title: '전라남도',
      districts: [
        '목포시', '여수시', '순천시', '나주시', '광양시', '담양군', 
        '곡성군', '구례군', '고흥군', '보성군', '화순군', '장흥군', 
        '강진군', '해남군', '영암군', '무안군', '함평군', '영광군', 
        '장성군', '완도군', '진도군', '신안군'
      ],
    ),
    RegionModel(
      title: '경상북도',
      districts: [
        '포항시', '경주시', '김천시', '안동시', '구미시', '영주시', 
        '영천시', '상주시', '문경시', '경산시', '군위군', '의성군', 
        '청송군', '영양군', '영덕군', '청도군', '고령군', '성주군', 
        '칠곡군', '예천군', '봉화군', '울진군', '울릉군'
      ],
    ),
    RegionModel(
      title: '경상남도',
      districts: [
        '창원시', '진주시', '통영시', '사천시', '김해시', '밀양시', 
        '거제시', '양산시', '의령군', '함안군', '창녕군', '고성군', 
        '남해군', '하동군', '산청군', '함양군', '거창군', '합천군'
      ],
    ),
    RegionModel(
      title: '제주특별자치도',
      districts: [
        '제주시', '서귀포시'
      ],
    ),
  ];

  static List<List<RegionModel>> get paginatedRegions {
    List<List<RegionModel>> pages = [];
    for (int i = 0; i < regions.length; i += 8) {
      int end = (i + 8 < regions.length) ? i + 8 : regions.length;
      pages.add(regions.sublist(i, end));
    }
    return pages;
  }

  static RegionModel? getRegionByTitle(String title) {
    try {
      return regions.firstWhere((region) => region.title == title);
    } catch (e) {
      return null;
    }
  }

  static List<String> getDistrictsByRegion(String regionTitle) {
    final region = getRegionByTitle(regionTitle);
    return region?.districts ?? [];
  }
}