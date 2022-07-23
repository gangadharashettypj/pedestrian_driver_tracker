#include <ESP8266WiFi.h>
const int trigPin = D6;
const int echoPin = D5;

//define sound velocity in cm/uS
#define SOUND_VELOCITY 0.034
#define CM_TO_INCH 0.393701

long duration;
float distanceCm;
float distanceInch;

#include <FirebaseESP8266.h>

// Provide the token generation process info.
#include <addons/TokenHelper.h>

// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

/* 1. Define the WiFi credentials */
#define WIFI_SSID "Nixbees11"
#define WIFI_PASSWORD "Praveen*2019"

/* 2. Define the API Key */
#define API_KEY "AIzaSyAss0uzJWQXKysM1ccmCT3txUgu_QVhvR0"

/* 3. Define the RTDB URL */
#define DATABASE_URL "smartjacket-6c368-default-rtdb.firebaseio.com" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app

/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "test@gmail.com"
#define USER_PASSWORD "12345678"

// Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

void setup(void) {
  Serial.begin(115200);
  Serial.println("");

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  // For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  // Or use legacy authenticate method
  // config.database_url = DATABASE_URL;
  // config.signer.tokens.legacy_token = "<database secret>";

  // To connect without auth in Test Mode, see Authentications/TestMode/TestMode.ino

  Firebase.begin(&config, &auth);

  Firebase.reconnectWiFi(true);

  pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
  pinMode(echoPin, INPUT); // Sets the echoPin as an Input
  pinMode(D8, OUTPUT);
  pinMode(D3, INPUT);
  pinMode(D4, INPUT);
}

void loop(void) {
  // Clears the trigPin
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(echoPin, HIGH);

  // Calculate the distance
  distanceCm = duration * SOUND_VELOCITY / 2;

  // Convert to inches
  distanceInch = distanceCm * CM_TO_INCH;

  // Prints the distance on the Serial Monitor
  //  Serial.print("Distance (cm): ");
  //  Serial.println(distanceCm);
//  Serial.print(digitalRead(D3));
  if (distanceCm < 50) {

    digitalWrite(D8, HIGH);
  }
  else if (!digitalRead(D4)) {
    Serial_Printf("Set alcohol... %s\n", Firebase.RTDB.setBool(&fbdo, F("/ped/alcohol"), true) ? "ok" : fbdo.errorReason().c_str());
    digitalWrite(D8, HIGH);
  }
  else if (!digitalRead(D3)) {
    Serial_Printf("Set accident... %s\n", Firebase.RTDB.setBool(&fbdo, F("/ped/accident"), true) ? "ok" : fbdo.errorReason().c_str());
    digitalWrite(D8, HIGH);
    delay(1000);
  }
  else {
    digitalWrite(D8, LOW);
  }

}
