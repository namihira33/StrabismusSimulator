import processing.serial.*;

Serial serial1;            
Serial serial2;            
String[] portList;        
boolean port1Selected = false;  
boolean port2Selected = false;
boolean isRotating = false;    

// 1番目のポートのデータ
ArrayList<Float> yawData1 = new ArrayList<Float>();
ArrayList<Float> servoData1 = new ArrayList<Float>();
ArrayList<Float> timeData1 = new ArrayList<Float>();

// 2番目のポートのデータ
ArrayList<Float> yawData2 = new ArrayList<Float>();
ArrayList<Float> servoData2 = new ArrayList<Float>();
ArrayList<Float> timeData2 = new ArrayList<Float>();

// 初期ジャイロ角度を保存する変数
float initialYaw1 = 0;
float initialYaw2 = 0;
boolean initialYaw1Set = false;
boolean initialYaw2Set = false;

float startTime = 0;
int maxPoints = 100;      
float graphMargin = 50;   

// CSVファイル用の変数
PrintWriter csvFile;
boolean isRecording = false;

void setup() {
  size(1200, 800);
  background(255);
  
  portList = Serial.list();
  
  println("利用可能なポート:");
  for (int i = 0; i < portList.length; i++) {
    println(i + ": " + portList[i]);
  }
  
  // CSVファイルの準備
  String timestamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "_" + 
                    nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  csvFile = createWriter("data_" + timestamp + ".csv");
  csvFile.println("Time,RelativeYaw1,RelativeServo1,RelativeYaw2,RelativeServo2");
  
  textAlign(LEFT, CENTER);
  textSize(14);
}

void draw() {
  background(255);
  
  if (!port1Selected || !port2Selected) {
    drawPortSelection();
  } else {
    drawGraphs();
    drawControls();
  }
}

void drawGraph(ArrayList<Float> data, String label, float x, float y, float w, float h, 
              color c, float minValue, float maxValue) {
  // グラフの枠を描画
  noFill();
  stroke(0);
  rect(x, y, w, h);
  
  // ラベルと現在値を描画
  fill(0);
  textAlign(LEFT, BOTTOM);
  text(label, x, y - 5);
  if (data.size() > 0) {
    text("Current: " + nf(data.get(data.size()-1), 0, 2), x + w - 100, y - 5);
  }
  
  // 軸の値を表示
  text(nf(minValue, 0, 0), x - 30, y + h);
  text(nf(maxValue, 0, 0), x - 30, y);
  text("0", x - 30, y + h/2);
  
  if (data.size() < 2) return;
  
  // データを描画
  stroke(c);
  noFill();
  beginShape();
  for (int i = Math.max(0, data.size() - maxPoints); i < data.size(); i++) {
    float px = map(i, Math.max(0, data.size() - maxPoints), data.size(), x, x + w);
    float py = map(data.get(i), minValue, maxValue, y + h, y);
    vertex(px, py);
  }
  endShape();
}

void drawPortSelection() {
  fill(0);
  text("利用可能なポート:", 50, 30);
  for (int i = 0; i < portList.length; i++) {
    text(i + ": " + portList[i], 50, 60 + i * 30);
  }
  
  if (!port1Selected) {
    text("1番目のポート（左目）を選択してください (数字キー)", 50, height - 80);
  } else if (!port2Selected) {
    text("2番目のポート（右目）を選択してください (数字キー)", 50, height - 50);
  }
}

void drawControls() {
  fill(0);
  text("a: ランダム回転開始", 10, height - 120);
  text("d: 初期位置移動", 10, height - 100);
  text("s: 回転停止", 10, height - 80);
  text("r: 記録開始/停止", 10, height - 60);
  text("q: プログラム終了", 10, height - 40);
  
  fill(isRotating ? color(0, 255, 0) : color(255, 0, 0));
  text("回転状態: " + (isRotating ? "ON" : "OFF"), width - 200, height - 60);
  
  fill(isRecording ? color(0, 255, 0) : color(255, 0, 0));
  text("記録状態: " + (isRecording ? "ON" : "OFF"), width - 200, height - 40);
}

void drawGraphs() {
  float graphHeight = (height - 2 * graphMargin) / 2;
  float graphWidth = (width - 3 * graphMargin) / 2;
  
  // ポート1のグラフ（左目: 初期角度60度）
  drawGraph(yawData1, "Relative Yaw 1 (degrees)", graphMargin, graphMargin, 
           graphWidth, graphHeight, color(255, 0, 0), -20, 20);
  drawGraph(servoData1, "Left Servo (relative to 60°)", graphMargin, graphMargin + graphHeight + 20, 
           graphWidth, graphHeight, color(0, 255, 0), -20, 20);
           
  // ポート2のグラフ（右目: 初期角度90度）
  drawGraph(yawData2, "Relative Yaw 2 (degrees)", 2 * graphMargin + graphWidth, graphMargin, 
           graphWidth, graphHeight, color(0, 0, 255), -20, 20);
  drawGraph(servoData2, "Right Servo (relative to 90°)", 2 * graphMargin + graphWidth, graphMargin + graphHeight + 20, 
           graphWidth, graphHeight, color(255, 165, 0), -20, 20);
}

void serialEvent(Serial port) {
  try {
    String input = port.readStringUntil('\n');
    if (input != null) {
      input = input.trim();
      println("受信データ: " + input);
      
      if (input.startsWith("時間") || input.startsWith("init") || input.startsWith("Commands")) {
        return;
      }
      
      String[] values = split(input, ',');
      if (values.length >= 3) {
        float time = float(values[0]) / 1000.0;
        float yaw = float(values[1]);
        float servo = float(values[2]);
        
        if (port == serial1) {
          // 左目の初期ヨー角度を設定
          if (!initialYaw1Set) {
            initialYaw1 = yaw;
            initialYaw1Set = true;
            println("左目初期ヨー角度設定: " + initialYaw1);
          }
          // 相対ヨー角度を計算
          float relativeYaw = yaw - initialYaw1;
          
          // サーボ角度も相対角度に変換（60度を0度として扱う）
          servo = servo - 60;
          updateData(timeData1, yawData1, servoData1, time, relativeYaw, servo);
          
        } else if (port == serial2) {
          // 右目の初期ヨー角度を設定
          if (!initialYaw2Set) {
            initialYaw2 = yaw;
            initialYaw2Set = true;
            println("右目初期ヨー角度設定: " + initialYaw2);
          }
          // 相対ヨー角度を計算
          float relativeYaw = yaw - initialYaw2;
          
          // サーボ角度も相対角度に変換（90度を0度として扱う）
          servo = servo - 90;
          updateData(timeData2, yawData2, servoData2, time, relativeYaw, servo);
        }
        
        // CSVに記録（相対角度で記録）
        if (isRecording && timeData1.size() > 0 && timeData2.size() > 0) {
          csvFile.println(time + "," + 
                         yawData1.get(yawData1.size()-1) + "," + 
                         servoData1.get(servoData1.size()-1) + "," + 
                         yawData2.get(yawData2.size()-1) + "," + 
                         servoData2.get(servoData2.size()-1));
          csvFile.flush();
        }
      }
    }
  } catch (Exception e) {
    println("データ解析エラー: " + e.getMessage());
  }
}

void updateData(ArrayList<Float> timeData, ArrayList<Float> yawData, 
                ArrayList<Float> servoData, float time, float yaw, float servo) {
  timeData.add(time);
  yawData.add(yaw);
  servoData.add(servo);
  
  if (timeData.size() > maxPoints) {
    timeData.remove(0);
    yawData.remove(0);
    servoData.remove(0);
  }
}

void keyPressed() {
  if (!port1Selected || !port2Selected) {
    int portIndex = key - '0';
    if (portIndex >= 0 && portIndex < portList.length) {
      try {
        if (!port1Selected) {
          serial1 = new Serial(this, portList[portIndex], 115200);
          serial1.bufferUntil('\n');
          port1Selected = true;
          println("ポート1（左目）: " + portList[portIndex] + "に接続しました");
        } else if (!port2Selected) {
          if (!portList[portIndex].equals(serial1.port.getPortName())) {
            serial2 = new Serial(this, portList[portIndex], 115200);
            serial2.bufferUntil('\n');
            port2Selected = true;
            println("ポート2（右目）: " + portList[portIndex] + "に接続しました");
            startTime = millis();
          } else {
            println("異なるポートを選択してください");
          }
        }
      } catch (Exception e) {
        println("ポートのオープンに失敗しました: " + e.getMessage());
      }
    }
  } else {
    if (key == 'a' || key == 'A') {
      // 'a'キーでリセット
      resetInitialValues();
      serial1.write('a');
      serial2.write('a');
      isRotating = true;
      println("ランダム回転開始コマンド送信");
    } else if (key == 'd' || key == 'D') {
      // 'd'キーでもリセット
      resetInitialValues();
      serial1.write('d');
      serial2.write('d');
      isRotating = true;
      println("初期位置移動コマンド送信");
    } else if (key == 's' || key == 'S') {
      serial1.write('s');
      serial2.write('s');
      isRotating = false;
      println("回転停止コマンド送信");
    } else if (key == 'r' || key == 'R') {
      isRecording = !isRecording;
      println(isRecording ? "記録開始" : "記録停止");
    } else if (key == 'q' || key == 'Q') {
      exit();
    }
  }
}

void resetInitialValues() {
  initialYaw1Set = false;
  initialYaw2Set = false;
  yawData1.clear();
  yawData2.clear();
  servoData1.clear();
  servoData2.clear();
  timeData1.clear();
  timeData2.clear();
  println("初期値をリセットしました");
}

void exit() {
  if (serial1 != null) serial1.stop();
  if (serial2 != null) serial2.stop();
  if (csvFile != null) csvFile.close();
  super.exit();
}
