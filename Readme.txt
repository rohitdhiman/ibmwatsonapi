
Platform-       iOS 
iOS Version-  9.0 or above
Xcode        -   7.0

Pre-requisites : Your MAC should be connected IBM intranet/internet. Tested on IBM w3 v17 Standards.

Introduction about App: 

Problem statement -  Currently “Voice based search option” is not available for IBM W3 portal for user. 

Solution using Watson APIs -  Voice to search feature is nowadays is very common and user friendly. So we have integrated two Watson services available on IBM Bluemix.

1.  Speech to Text
2.  Text to Speech

So we have integrated mention Watson Api to overcome problem.

Result: 

Using shared github code user able to search on IBM w3 portal using Voice based input.

Note: 

Refer attached Video for more information about Voice based search on IBM w3 portal and Google.

There are two videos attached for reference.
1. Video shows output using IBM W3 portal/Google search

Steps to Run code:

1.  Open terminal on MAC
2.  Clone the code at your local system using below github repository:  git@github.com:rohitdhiman/ibmwatsonspeachtotext.git    
3.  Run below command on MAC terminal
     git clone git@github.com:rohitdhiman/ibmwatsonspeachtotext.git

4. Open the code location 
5. Open Watson_Speech.xcodeproj in xcode 7 or above version
6. Build and run the code in iPhone simulator 
7. Now, tap on “Tap for voice based search on IBM w3” button.
8. Provide your voice based input. for ex : you should speak word to search on IBM w3. (Refer attached video for more reference.)
9. App will connect with Watson “Speech to Text” and “Text to Voice” services API. It will convert your voice based input as text and voice versa. 
10.  Result will be displayed in device/simulator external Safari browser.
 

Thanks for using app. Your feedback/suggestions are most welcome.










