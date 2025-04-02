//import 'package:clipboard/clipboard.dart';
import 'package:beldex_browser/src/utils/themes/dark_theme_provider.dart';
import 'package:beldex_browser/src/widget/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';



class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
 Color getColor(DarkThemeProvider themeProvider){
   return themeProvider.darkTheme ? const Color(0xffEDEDED) : const Color(0xff24242F);
   
 }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    var mHeight = MediaQuery.of(context).size.height;
    //var mWidth = MediaQuery.of(context).size.width;
    final screenSize = MediaQuery.of(context).size;
     const double pixelFontSize = 12;
    final double fontSizeInDp = (pixelFontSize / screenSize.width) * screenSize.width;
    return Container(
        child: Scaffold(
      appBar: normalAppBar(context, 'About', themeProvider),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: themeProvider.darkTheme
                    ? const Color(0xff282836)
                    : const Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(10)),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: RawScrollbar(
                thumbColor: const Color(0xff3EC745),
                // themeProvider.darkTheme
                //     ?const Color(0xff4D4D64)
                //     :const Color(0xff3EC745), //Color(0xffC7C7C7),
                //controller: scrollController,
                thumbVisibility: true,
                thickness: 5,
                radius: Radius.circular(10),
                child: Container(
                  color: themeProvider.darkTheme
                      ?const Color(0xff111117)
                      :const Color(0xffE3E3E3),
                  padding: EdgeInsets.only(right: 5.0),
                  child: SingleChildScrollView(
                      child: Container(
                    decoration: BoxDecoration(
                        color: themeProvider.darkTheme
                            ?const Color(0xff282836)
                            :const Color(0xffF3F3F3)),
                    padding: EdgeInsets.only(
                        left: mHeight * 0.03 / 3, right: mHeight * 0.06 / 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                         text: """Beldex is an ecosystem of decentralized and confidential preserving applications. The Beldex Browser app is one among this ecosystem which also consists of apps such as BChat, BelNet, and the Beldex protocol. The Beldex Browser is your gateway to a seamless and confidential online experience, where your data remains yours alone. Built on a robust blockchain infrastructure, Beldex browser ensures confidentiality and anonymity to its users.""",
                          style: TextStyle(
                              fontSize: fontSizeInDp, 
                              color: getColor(themeProvider),//Color(0xff56566F)
                              height: 1.5
                              ),
                          textAlign: TextAlign.justify,
                        ),
                        TextWidget(
                         text: """ \n At Beldex, we believe in empowering individuals with the fundamental right to control their digital footprint. The Beldex Browser is designed to provide a secure and confidential online environment for users to communicate and interact with the digital world.""",
                          style: TextStyle(
                              fontSize: fontSizeInDp, 
                              color: getColor(themeProvider),
                              height: 1.5
                              ),
                          textAlign: TextAlign.justify,
                        ),
                        TextWidget(
                          text:"\nBNS",
                          style: TextStyle(
                              fontSize:fontSizeInDp, //mHeight * 0.060 / 3,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w800,
                              color: themeProvider.darkTheme
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        TextWidget(
                           text: """The Beldex browser supports BNS domains. BNS domains are inherently hosted on BelNet. They can only be accessed by connecting to BelNet. However, since the Beldex Browser has BelNet in-built, users can freely access BNS domains.""",
                            style: TextStyle(
                                
                               fontSize:fontSizeInDp, 
                                color: getColor(themeProvider),
                                height: 1.5,
                                ),
                            textAlign: TextAlign.justify),
                        TextWidget(
                         text: "\nMNApps",
                          style: TextStyle(
                              fontSize:fontSizeInDp,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w800,
                              color: themeProvider.darkTheme
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        Text(
                            """As the browser itself supports BelNet as an added confidentiality feature, users can easily access MNApps hosting on the .bdx domain address.""",
                            style: TextStyle(
                                fontSize:fontSizeInDp, 
                                color: getColor(themeProvider),
                                height: 1.5
                                ),
                            textAlign: TextAlign.justify),
                        Text(
                          "\nCross Platform Access",
                          style: TextStyle(
                              fontSize:fontSizeInDp,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w800,
                              color: themeProvider.darkTheme
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        TextWidget(
                          text:  """The Beldex browser is cross-platform as it is being developed for both mobile and desktop devices.""",
                            style: TextStyle(
                                fontSize:fontSizeInDp,
                                color: getColor(themeProvider),
                                fontWeight: FontWeight.w400,
                                height: 1.5
                                ),
                            textAlign: TextAlign.justify),
                        TextWidget(
                         text: "\nKey Features",
                          style: TextStyle(
                              fontSize:fontSizeInDp * 1.2,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w800,
                              color: themeProvider.darkTheme
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        TextWidget(
                           text: """\nFollowing are the features available on the Beta version of the Beldex browser application. More features will be added to the alpha version.\n""",
                            style: TextStyle(
                                fontSize:fontSizeInDp,
                                color: getColor(themeProvider),
                                height: 1.5
                                ),
                            textAlign: TextAlign.justify),
                        BulletItem(
                          text:
                              """Blocks Javascript: The Beldex browser prioritizes user security by blocking Javascript, thereby reducing the risk of malicious scripts that could compromise user confidentiality and security. This ensures a safe browsing experience and protects users from threats that involve javascript vulnerabilities.""",
                          mHeight: mHeight,
                          fontSizeInDp: fontSizeInDp,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        BulletItem(
                          text:
                              """Blocks Cookies: Cookies collect a user’s personal information that help determine their behavioural and usage patterns. This in-turn helps the website to show relevant ads, manage active sessions, and provide big data analytics.""",
                          mHeight: mHeight,
                          fontSizeInDp: fontSizeInDp,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        BulletItem(
                          text:
                              """IP Address is Masked: The browser’s in-built dVPN, the BelNet, masks the client IP address from the websites they visit. This provides confidentiality and anonymity to the user and prevents websites from identifying and tracking the user based on their IP address.""",
                          mHeight: mHeight,
                          fontSizeInDp: fontSizeInDp,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        BulletItem(
                          text:
                              """Location is Obfuscated: To further enhance confidentiality, the browser obfuscates the user's location, making it challenging for websites and third parties to determine the actual geographical location of the user. This ensures that users can browse without revealing sensitive information about their whereabouts.""",
                          mHeight: mHeight,
                          fontSizeInDp: fontSizeInDp,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        BulletItem(
                          text:
                              """No Metadata is Collected: The browser abstains from collecting metadata, ensuring that no additional information about the user's browsing habits or preferences is stored. This minimizes the risk of data leakage and unauthorized access to user information.""",
                          mHeight: mHeight,
                          fontSizeInDp: fontSizeInDp,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        BulletItem(
                          text:
                              """In-built dVPN Service: The inclusion of an in-built decentralized VPN (dVPN) service like BelNet encrypts the user’s internet traffic and ensures a secure and confidential connection for users.""",
                          mHeight: mHeight,
                          fontSizeInDp: fontSizeInDp,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        BulletItem(
                          text:
                              """Unrestricted Access: The Beldex browser promotes unrestricted access to information on the Internet, thus aiding free speech and resistance to censorship. Users can easily access geo-restricted content.""",
                          mHeight: mHeight,
                          fontSizeInDp: fontSizeInDp,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        BulletItem(
                          text:
                              """Censorship-resistance: By employing the Beldex blockchain and a network of decentralized nodes, Beldex browser promotes resistance to censorship. The outage of no single server can restrict access to the service.\n""",
                          mHeight: mHeight,
                          fontSizeInDp: fontSizeInDp,
                        ),
                        BulletItem(
                          text:
                              """Ad-blocker: Block intrusive ads, trackers, and pop-ups for a cleaner, distraction-free browsing experience. Enjoy faster page loads and reduced data usage while maintaining complete control over your online interactions.\n""",
                          mHeight: mHeight,
                          fontSizeInDp: fontSizeInDp,
                        ),
                        BulletItem(
                          text:
                              """Beldex AI: Get instant answers to your queries with BeldexAI, an intelligent assistant that responds to your questions and queries based on website content. Whether you're searching for specific information or need quick insights, BeldexAI enhances your browsing experience with contextual and tailored responses.\n""",
                          mHeight: mHeight,
                          fontSizeInDp: fontSizeInDp,
                        ),
                        TextWidget(
                           text: """\nThus, the Beldex Browser offers a simple and secure haven for users seeking confidentiality in an increasingly interconnected world. Join us on the journey towards a more confidential and secure digital future. Experience the freedom to surf, communicate, and explore the internet without compromising your confidentiality. Beldex Network – Where Confidentiality Meets Innovation.""",
                            style: TextStyle(
                                fontSize:fontSizeInDp,
                                height: 1.5,
                                color: themeProvider.darkTheme
                                    ?const Color(0xffEDEDED) //Color(0xffA1A1C1)
                                    : const Color(0xff24242F) //Color(0xff56566F)
                                ),
                            textAlign: TextAlign.justify),
                        Center(
                          child: TextWidget(
                           text: "\nCredits: Beldex & BelNet.\n",
                            style: TextStyle(
                                fontSize:fontSizeInDp,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w800,
                                color: themeProvider.darkTheme
                                    ? const Color(0xff6D6D81)
                                    :const Color(0xffC5C5C5)),
                          ),
                        ),
                      ],
                    ),
                  )),
                ),
              ),
            )),
      ),
    ));
  }
   AppBar normalAppBar(
      BuildContext context, String title, DarkThemeProvider themeProvider) {
    return AppBar(
      backgroundColor:
          themeProvider.darkTheme ? const Color(0xff171720) : const Color(0xffFFFFFF),
      centerTitle: true,
      leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/images/back.svg',
            color: themeProvider.darkTheme ? Colors.white :const Color(0xff282836),
            height: 30,
          )),
      title: TextWidget(text:title, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}



class BulletItem extends StatelessWidget {
  final String text;
  final double mHeight;
  final double fontSizeInDp;
  const BulletItem({Key? key, required this.text, required this.mHeight, required this.fontSizeInDp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8.0), // Adjust horizontal padding here
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 5.0, right: 8.0),
            height: 3.0,
            width: 3.0,
            decoration: BoxDecoration(
              color: themeProvider.darkTheme
                  ? Colors.white
                  : Colors.black, // Adjust color as needed
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: TextWidget(text: text,
                style: TextStyle(
                    fontSize:fontSizeInDp, 
                    color: themeProvider.darkTheme
                        ? const Color(0xffEDEDED) //Color(0xffA1A1C1)
                        :const Color(0xff24242F) //Color(0xff56566F)
                    ),
                textAlign: TextAlign.justify),
          ),
        ],
      ),
    );
  }
}
