import 'package:flutter/material.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/common_widget/custom_arc_painter.dart';
import 'package:untitled/common_widget/income_home_row.dart';
import 'package:untitled/common_widget/segment_button.dart';
import 'package:untitled/common_widget/status_button.dart';
import 'package:untitled/common_widget/up_coming_bill_row.dart';
import 'package:untitled/view/settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();

}

class _HomeViewState extends State<HomeView> {

  bool isIncome = true;
  List incomeArr = [
    {"name":"Monthly Salary", "icon":"assets/img/salary.jpeg", "price":"100,000"},
    {"name":"Bonuses", "icon":"assets/img/bonus.jpeg", "price":"30,000"},
    {"name":"Overtime Pay", "icon":"assets/img/overtime.jpeg", "price":"20,000"},
    {"name":"Teaching Allowances ", "icon":"assets/img/allowence.jpeg", "price":"50,000"},
  ];
  List billArr = [
    {"name":"Housing & Utilities", "date":DateTime(2025,05,1), "price":"100,000"},
    {"name":"Food & Groceries","date":DateTime(2025,05,1), "price":"30,000"},
    {"name":"Transportation", "date":DateTime(2025,05,1), "price":"20,000"},
    {"name":"Communication & Subscriptions ", "date":DateTime(2025,05,1), "price":"50,000"},
    {"name":"Family & Dependents ", "date":DateTime(2025,05,1),"price":"50,000"},
    {"name":"Health & Insurance", "date":DateTime(2025,05,1), "price":"50,000"},
    {"name":"Miscellaneous & Personal Expenses", "date":DateTime(2025,05,1), "price":"50,000"},
    {"name":"Debt & Financial Commitments", "date":DateTime(2025,05,1), "price":"50,000"},
  ];

  @override
  Widget build(BuildContext context) {
    
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.gray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: media.width * 1.1,
              decoration: BoxDecoration(
                  color: TColor.gray70.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/img/home_bg.png"),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        padding:  EdgeInsets.only(bottom: media.width * 0.05),
                        width: media.width * 0.72,
                        height: media.width * 0.72,
                        child: CustomPaint(
                          painter: CustomArcPainter(end: 220, ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          children: [
                            Spacer(),
                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const SettingsView()));
                                },
                                icon: Image.asset("assets/img/settings.png",
                                    width: 25,
                                    height: 25,
                                    color: TColor.gray30))
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Image.asset("assets/img/app_logo.png",
                          width: media.width * 0.25, fit: BoxFit.contain),
                      SizedBox(
                        height: media.width * 0.07,
                      ),
                      Text(
                        "\$1,235",
                        style: TextStyle(
                            color: TColor.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: media.width * 0.055,
                      ),
                      Text(
                        "This month bills",
                        style: TextStyle(
                            color: TColor.gray40,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: media.width * 0.07,
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: TColor.border.withOpacity(0.15),
                            ),
                            color: TColor.gray60.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "See your budget",
                            style: TextStyle(
                                color: TColor.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: StatusButton(
                                title: "Active bills",
                                value: "12",
                                statusColor: TColor.secondary,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: StatusButton(
                                title: "Highest bills",
                                value: "\$19.99",
                                statusColor: TColor.primary10,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: StatusButton(
                                title: "Lowest bills",
                                value: "\$5.99",
                                statusColor: TColor.secondaryG,
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),),
              child: Row(
                children: [
                  Expanded(child: 
                      SegmentButton(title: 'Our Income', onPress: () {
                        setState(() {
                          isIncome = !isIncome;
                        });
                      }, isActive: !isIncome,),

                  ),


                  Expanded(child:
                  SegmentButton(title: 'Upcoming bills', onPress: () {
                    setState(() {
                      isIncome = !isIncome;
                    });
                  }, isActive: isIncome,),

                  ),
                ],
              ),
            ),
             if(!isIncome)
             ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: incomeArr.length, // Replace with your actual item count
                itemBuilder: (context, index) {
                var incObj = incomeArr[index] as Map? ?? {};
                return IncomeHomeRow(onPress: (){

                }, incObj: incObj);

                },
              ),
            if (isIncome)
              ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: billArr.length,
                  itemBuilder: (context, index) {
                    var sObj = billArr[index] as Map? ?? {};

                    return UpcomingBillRow(
                      sObj: sObj,
                      onPressed: () {},
                    );
                  }),
            const SizedBox(
              height: 110,
            ),




          ],
        ),
      ),
    );
  }
}
