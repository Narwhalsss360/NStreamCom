#include <NStreamCom.h>

/*
    This code only works with compatible code on other end.
*/

NStreamCom com = NStreamCom(&Serial);

unsigned long lastSend = 0;

void serialEvent()
{
    NStreamData newData = com.parse();

    if (INVLAID_DATA(newData))
    {
        Serial.println("Invalid data");
        return;
    }

    if (newData.id == 1)
    {
        unsigned long number = *(unsigned long*)newData.data; //Reinterpret cast.
        Serial.print("Number recieved ");
        Serial.println(number);
    }
    else
    {
        Serial.println("Other data recieved");
    }
}

void setup()
{
    Serial.begin(1000000);
}

void loop()
{
    if (millis() - lastSend > 1000)
    {
        lastSend = millis();
        unsigned long boardTime = millis();
        com.send(1, &boardTime, sizeof(boardTime));
    }
}