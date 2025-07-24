import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AdvertisementRegistrationView extends StatefulWidget {
  const AdvertisementRegistrationView({super.key});

  @override
  State<AdvertisementRegistrationView> createState() => _AdvertisementRegistrationViewState();
}

class _AdvertisementRegistrationViewState extends State<AdvertisementRegistrationView> {
  int _selectedAdType = 0; // 0: 기업광고, 1: 제품광고
  DateTime _selectedMonth = DateTime(2025, 5);
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSelectingRange = false;

  int get _selectedDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  int get _totalPrice {
    return _selectedDays * 3000;
  }

  String get _formattedDateRange {
    if (_startDate == null || _endDate == null) return '';
    return '${_startDate!.year}.${_startDate!.month.toString().padLeft(2, '0')}.${_startDate!.day.toString().padLeft(2, '0')} ~ ${_endDate!.year}.${_endDate!.month.toString().padLeft(2, '0')}.${_endDate!.day.toString().padLeft(2, '0')}';
  }

  List<DateTime> get _selectedDateRange {
    if (_startDate == null || _endDate == null) return [];
    List<DateTime> dates = [];
    DateTime current = _startDate!;
    while (current.isBefore(_endDate!) || current.isAtSameMomentAs(_endDate!)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_startDate == null || _endDate != null) {
        // Start new selection
        _startDate = date;
        _endDate = null;
        _isSelectingRange = true;
      } else {
        // Complete selection
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
        _isSelectingRange = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAdTypeSelection(),
            _buildCalendarSection(),
            _buildPurchaseInfo(),
            _buildPurchaseButton(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/profile');
          }
        },
      ),
      title: Text(
        '광고등록',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildAdTypeSelection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '광고종류',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAdType = 0;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _selectedAdType == 0 ? const Color(0xFF1E3A5F) : Colors.white,
                      border: Border.all(
                        color: _selectedAdType == 0 ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        '기업광고',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: _selectedAdType == 0 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAdType = 1;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _selectedAdType == 1 ? const Color(0xFF1E3A5F) : Colors.white,
                      border: Border.all(
                        color: _selectedAdType == 1 ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        '제품광고',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: _selectedAdType == 1 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20.sp,
                color: Colors.black,
              ),
              SizedBox(width: 8.w),
              Text(
                '날짜와 시간을 선택해 주세요',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildMonthSelector(),
          SizedBox(height: 20.h),
          _buildCalendar(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
            });
          },
          icon: Icon(Icons.arrow_back_ios, size: 16.sp, color: Colors.grey[600]),
        ),
        Text(
          '${_selectedMonth.year}.${_selectedMonth.month}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
            });
          },
          icon: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
            ),
            child: Row(
              children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Calendar grid
          ...List.generate(6, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                final isValidDay = dayNumber > 0 && dayNumber <= daysInMonth;
                
                if (!isValidDay) {
                  return Expanded(
                    child: Container(height: 40.h),
                  );
                }

                final currentDate = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
                final isInSelectedRange = _selectedDateRange.any((date) => 
                  date.year == currentDate.year && 
                  date.month == currentDate.month && 
                  date.day == currentDate.day
                );
                final isStartDate = _startDate != null && 
                  _startDate!.year == currentDate.year && 
                  _startDate!.month == currentDate.month && 
                  _startDate!.day == currentDate.day;
                final isEndDate = _endDate != null && 
                  _endDate!.year == currentDate.year && 
                  _endDate!.month == currentDate.month && 
                  _endDate!.day == currentDate.day;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onDateTap(currentDate),
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: isInSelectedRange 
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isInSelectedRange ? Colors.white : Colors.black,
                                fontWeight: isInSelectedRange ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isStartDate)
                              Positioned(
                                bottom: 2.h,
                                child: Text(
                                  '무터',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isEndDate)
                              Positioned(
                                bottom: 2.h,
                                child: Text(
                                  '까지',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPurchaseInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildInfoRow('구매일수', _selectedDays > 0 ? '${_selectedDays}일' : '0일'),
          SizedBox(height: 12.h),
          _buildInfoRow('광고일', _formattedDateRange.isNotEmpty ? _formattedDateRange : '날짜를 선택해주세요'),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            height: 1.h,
            color: Colors.black,
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '${_totalPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}원',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            '구매이후 48시간 이내에 환불이 가능하며, 사용중인\n경우에는 환불이 불가능 합니다.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton() {
    final isEnabled = _selectedDays > 0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: isEnabled ? () {
          _showPurchaseDialog();
        } : null,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isEnabled ? const Color(0xFF1E3A5F) : Colors.grey[400],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              '구매',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '광고 구매',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '광고를 구매하시겠습니까?\n\n구매일수: ${_selectedDays}일\n광고일: $_formattedDateRange\n총 금액: ${_totalPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}원',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processPurchase();
              },
              child: Text(
                '구매',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1E3A5F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _processPurchase() {
    // TODO: Implement in-app purchase logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '광고 구매가 완료되었습니다.',
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}