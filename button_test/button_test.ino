int val = 0;

void setup() {
  // put your setup code here, to run once:
  pinMode(13, OUTPUT);
  pinMode(12, INPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  val = digitalRead(12);
  digitalWrite(13, val);
}
