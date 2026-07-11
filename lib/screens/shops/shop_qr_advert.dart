import 'package:flutter/material.dart';

class ShopQrBanner extends StatefulWidget {
  const ShopQrBanner({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;


  @override
  State<ShopQrBanner> createState() => _ShopQrBannerState();
}


class _ShopQrBannerState extends State<ShopQrBanner>
    with SingleTickerProviderStateMixin {


  late AnimationController _controller;

  late Animation<double> _scale;


  @override
  void initState() {
    super.initState();


    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);


    _scale = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 2),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(14),

        gradient: const LinearGradient(
          colors: [
            Colors.orange,
            Colors.deepOrange,
          ],
        ),

      ),


      child: Padding(

        padding: const EdgeInsets.all(20),


        child: Row(

          children: [


            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,


                mainAxisAlignment:
                    MainAxisAlignment.center,


                children: [


                  const Text(

                    "OPEN YOUR SHOP ON MANGOHUB",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),

                  ),



                  const SizedBox(height: 8),



                  const Text(

                    "Sell online, get your QR Code, "
                    "and let customers scan your shop.",

                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),

                  ),



                  const SizedBox(height: 15),



                  ElevatedButton(

                    onPressed: widget.onTap,


                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.white,

                      foregroundColor: Colors.deepOrange,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                      ),

                    ),


                    child: const Text(
                      "CREATE SHOP",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  )


                ],

              ),

            ),



            ScaleTransition(

              scale: _scale,


              child: const Icon(

                Icons.qr_code_2,

                color: Colors.white,

                size: 80,

              ),

            )

          ],

        ),

      ),

    );

  }
}