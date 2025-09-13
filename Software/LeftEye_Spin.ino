#include <Wire.h>
#include <MPU6050.h>
#include <MadgwickAHRS.h>
#include <Servo.h>

Madgwick filter;
MPU6050 mpu;
Servo leftServo;

const int SERVO_PIN = 2;
const unsigned long MOVEMENT_INTERVAL = 1000; // 1秒ごとに回転
const float INITIAL_ANGLE = 60.0;  // 左目の初期角度（60度）
const float ANGLE_RANGE = 15.0;    // 初期角度からの変動範囲（±15度）

// 回転の範囲を定義
const float MIN_ANGLE = INITIAL_ANGLE - ANGLE_RANGE;  // 45度
const float MAX_ANGLE = INITIAL_ANGLE + ANGLE_RANGE;  // 75度

float currentAngle = INITIAL_ANGLE;
float targetAngle = INITIAL_ANGLE;
bool rotating = false;
unsigned long lastMovementTime = 0;
float yaw = 0.0f;
unsigned long lastYawUpdateTime = 0;

// 乱数生成用の変数
const unsigned long RANDOM_SEED = 12345;  // 固定のシード値
unsigned long randomCallCount = 0;  // 乱数生成回数のカウンター

void setup() {
  Serial.begin(115200);
  
  // 固定のシードで乱数初期化
  randomSeed(RANDOM_SEED);
  
  // MPU6050の初期化
  Serial.println("Initializing MPU6050...");
  while(!mpu.begin(MPU6050_SCALE_2000DPS, MPU6050_RANGE_2G)) {
    Serial.println("Could not find MPU6050");
    delay(500);
  }
  Serial.println("MPU6050 initialized!");
  
  // ジャイロセンサーのキャリブレーション
  mpu.calibrateGyro();
  
  // Madgwickフィルターの初期化
  filter.begin(100);
  
  // サーボモーターの初期化と初期位置への移動
  leftServo.attach(SERVO_PIN);
  moveToInitialPosition();
  
  Serial.println("Initialization complete");
  Serial.println("Commands:");
  Serial.println("a: Start synchronized random movement");
  Serial.println("s: Stop movement");
  Serial.println("d: Return to initial position");
  Serial.println("Time(ms),Yaw,ServoAngle,RandomCount");
}

void loop() {
  if (Serial.available() > 0) {
    char input = Serial.read();
    if (input == 'a') {
      rotating = true;
      randomCallCount = 0;  // カウンターリセット
      Serial.println("Random movement started");
    } else if (input == 's') {
      rotating = false;
      Serial.println("Movement stopped");
    } else if (input == 'd') {
      moveToInitialPosition();
    }
  }

  unsigned long currentTime = millis();
  updateSensorData();
  
  if (currentTime - lastMovementTime >= MOVEMENT_INTERVAL && rotating) {
    // 新しいランダムな目標角度を設定
    generateNewTargetAngle();
    moveServoToTarget();
    lastMovementTime = currentTime;
  }
  
  printData();
  delay(10);
}

void generateNewTargetAngle() {
  // 乱数生成回数をインクリメント
  randomCallCount++;
  
  // ランダムな角度を生成（小数点以下2桁まで）
  float randomValue = random(4500, 7501) / 100.0;  // 45.00度から75.00度
  targetAngle = randomValue;
  
  // 範囲内に収める
  targetAngle = constrain(targetAngle, MIN_ANGLE, MAX_ANGLE);
}

void moveServoToTarget() {
  currentAngle = targetAngle;
  leftServo.write(round(currentAngle));
}

void updateSensorData() {
  Vector normAccel = mpu.readNormalizeAccel();
  Vector normGyro = mpu.readNormalizeGyro();
  
  filter.updateIMU(normGyro.XAxis, normGyro.YAxis, normGyro.ZAxis,
                   normAccel.XAxis, normAccel.YAxis, normAccel.ZAxis);
                   
  unsigned long currentTime = millis();
  float deltaTime = (currentTime - lastYawUpdateTime) / 1000.0f;
  yaw += normGyro.ZAxis * deltaTime;
  
  lastYawUpdateTime = currentTime;
}

void moveToInitialPosition() {
  rotating = false;
  currentAngle = INITIAL_ANGLE;
  targetAngle = INITIAL_ANGLE;
  leftServo.write(round(INITIAL_ANGLE));
  Serial.println("Moving to initial position (60 degrees)");
}

void printData() {
  Serial.print(millis());
  Serial.print(",");
  Serial.print(yaw);
  Serial.print(",");
  Serial.println(currentAngle);
}