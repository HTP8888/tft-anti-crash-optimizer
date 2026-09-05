# 🛡️ CẨM NANG CỨU HỘ: KHẮC PHỤC TREO / ĐƠ MÁY KHI CHƠI ĐẤU TRƯỜNG CHÂN LÝ (TFT)
### 👉 Dành riêng cho anh em game thủ dùng Laptop & PC có Card đồ họa tích hợp AMD Radeon (APU Ryzen)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Windows-10%20%7C%2011%20(64--bit)-blue)](https://www.microsoft.com/windows)
[![AMD Ryzen](https://img.shields.io/badge/AMD-Ryzen%20APU%20(Vega%20%2F%20Radeon%20Graphics)-ED1C24)](https://www.amd.com)
[![Game](https://img.shields.io/badge/Riot%20Games-Teamfight%20Tactics%20(ĐTCL)-0AC8B9)](https://teamfighttactics.leagueoflegends.com/)

---

## 📢 Gửi anh em cờ thủ ĐTCL sử dụng máy AMD!

Có phải bạn đang dùng một chiếc Laptop mỏng nhẹ hoặc PC văn phòng trang bị vi xử lý **AMD Ryzen** (như Ryzen 5 4600H, 5600H, Ryzen 7 4800H, 5700U, 5800H, 6800H...) sử dụng **Card đồ họa tích hợp AMD Radeon Graphics (Vega 6, Vega 7, Vega 8, 680M...)** và gặp phải tình trạng:

* Máy cấu hình rất khỏe (CPU 6 - 8 nhân, RAM 16GB), chơi LMHT hay các game khác đạt 100 - 150 FPS mượt mà.
* Nhưng **hễ cứ bấm vào trận Đấu Trường Chân Lý (bản độc lập mới)** là màn hình bị khựng lại, chuột đứng im, game đơ cứng hoặc Windows treo hoàn toàn buộc phải đè nút nguồn để khởi động lại?
* Cắm thêm màn hình ngoài (chơi 2 màn hình) hoặc lỡ `Alt + Tab` ra ngoài xem đội hình là y như rằng bị treo đơ máy?

> [!NOTE]
> **ĐỪNG VỘI HOANG MANG:** Máy tính hay Card màn hình của bạn **HOÀN TOÀN KHÔNG HỎNG VÀ KHÔNG HỀ YẾU!**  
> Đây là lỗi xung đột phần mềm 100% giữa động cơ game mới của Riot Games với cơ chế điều khiển của Windows và trình điều khiển (driver) của card tích hợp AMD.

---

## 🔍 Vì sao máy dùng Card tích hợp AMD lại bị treo đơ? (Giải thích dễ hiểu)

Sau khi nhóm kỹ thuật trích xuất và giải mã hàng trăm dòng nhật ký lỗi (`TFT.log`) từ chính các máy bị treo, nguyên nhân thực tế bao gồm:

1. **Bản ĐTCL mới (Unreal Engine 5) tự động ép card chạy DirectX 12:**
   * Bản TFT độc lập mới được Riot chuyển sang động cơ đồ họa Unreal Engine. Khi khởi động, game tự ý nạp DirectX 12.
   * Tuy nhiên, kiến trúc card onboard AMD Vega khi xử lý bộ đổ bóng (Shader) trên DirectX 12 của engine này bị lỗi treo luồng đồ họa, tạo ra lỗi chí mạng: **`DXGI_ERROR_DEVICE_HUNG (Card đồ họa bị treo cứng)`**.
   * *Đó là lý do tại sao Riot ra thông báo: Cấu hình tối ưu và chuẩn nhất của game là **DirectX 11**!*

2. **Cơ chế "quá nhiệt tình" của Windows (TdrDelay = 2 giây):**
   * Mặc định, Windows có bộ hẹn giờ bảo vệ: nếu card đồ họa không phản hồi trong **2 giây**, Windows sẽ nghĩ card đã "chết" và tự động gửi lệnh ngắt/khởi động lại card.
   * Với card onboard, khi vào trận hoặc khi bạn di chuột qua lại giữa 2 màn hình, card cần khoảng 2.5 - 2.8 giây để tái tạo lại hình ảnh. Windows thấy quá 2 giây liền "chém" luôn card đồ họa, làm máy bạn đen thui hoặc treo cứng ngắc!

3. **Card tích hợp bị "nghẹt thở" vì chia sẻ RAM chung (Shared VRAM):**
   * Card tích hợp không có bộ nhớ riêng như card rời mà phải mượn chung RAM với Windows.
   * Nếu máy bạn đang bật ngầm giả lập Android (BlueStacks), máy ảo Docker, WSL, hoặc các ứng dụng chèn lớp phủ như Overwolf/MetaTFT, bộ nhớ RAM khả dụng tụt dốc khiến card onboard không đủ bộ nhớ để tải tướng và hiệu ứng bàn cờ.

---

## 🚀 HƯỚNG DẪN CÀI ĐẶT & SỬ DỤNG TỪ ĐẦU (GETTING STARTED)

Bạn có thể lựa chọn 1 trong 3 cách sau để cài đặt và kích hoạt bộ tối ưu trên máy của mình:

---

### 🟢 Cách 1: Tải nhanh 1-Click (Dành cho anh em muốn nhanh gọn, không cần cài Git)

1. **Tải file công cụ về máy:**
   * Nhấp chuột vào link tải trực tiếp file: **[`ToiUu_ChoiGame.bat`](https://raw.githubusercontent.com/HTP8888/tft-anti-crash-optimizer/main/ToiUu_ChoiGame.bat)** $\rightarrow$ bấm `Ctrl + S` để lưu về máy.
   * Hoặc ở đầu trang GitHub này, bấm vào nút màu xanh **`Code`** $\rightarrow$ chọn **`Download ZIP`** $\rightarrow$ giải nén thư mục ra.
2. **Đưa ra màn hình chính:**
   * Sao chép tệp `ToiUu_ChoiGame.bat` ra ngoài **Desktop (Màn hình chính)** để tiện dùng mỗi khi chơi game.
3. **Kích hoạt:**
   * Nhấp chuột phải vào `ToiUu_ChoiGame.bat` $\rightarrow$ chọn **Run as Administrator** (Chạy với quyền Quản trị viên).
   * Bấm **Yes** khi hộp thoại Windows hiện lên hỏi quyền Admin.
4. **Xong!**
   * Công cụ tự động quét tìm thư mục game trên mọi ổ đĩa (C:, D:, E:...), khóa DirectX 11, dọn sạch Shader lỗi của AMD và nâng thời gian chờ GPU lên 30 giây trong vòng 3 giây.
   * Cửa sổ tự tắt, bạn mở Riot Client và bắt đầu vào trận ĐTCL!

---

### 🔵 Cách 2: Sử dụng lệnh Git & PowerShell (Dành cho Developer / Game thủ thích dùng dòng lệnh)

Dành cho những bạn đã cài đặt **Git** trên máy và muốn clone repository về để quản lý hoặc chạy script tự động:

#### Bước 1: Mở Terminal dưới quyền Administrator
* Nhấn phím `Windows + S`, gõ `PowerShell` (hoặc `cmd`).
* Nhấp chuột phải vào **Windows PowerShell** $\rightarrow$ chọn **Run as Administrator**.

#### Bước 2: Clone kho lưu trữ về máy
Chạy dòng lệnh sau để tải toàn bộ mã nguồn về máy:
```bash
git clone https://github.com/HTP8888/tft-anti-crash-optimizer.git
```

#### Bước 3: Di chuyển vào thư mục dự án
```bash
cd tft-anti-crash-optimizer
```

#### Bước 4: Thực thi công cụ tối ưu
Bạn có thể chọn 1 trong 2 cách chạy dòng lệnh sau:

* **Lựa chọn 2A - Chạy file Batch tự động:**
  ```cmd
  .\ToiUu_ChoiGame.bat
  ```

* **Lựa chọn 2B - Chạy kịch bản PowerShell tự động quét ổ đĩa:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\Setup_DX11_Optimizer.ps1
  ```

> [!TIP]
> **Nếu bạn cài đặt game ở một thư mục đặc biệt riêng** (không nằm ở các đường dẫn mặc định của Riot Games), bạn có thể truyền thẳng đường dẫn đó vào script:
> ```powershell
> powershell -ExecutionPolicy Bypass -File .\Setup_DX11_Optimizer.ps1 -CustomPath "D:\ThuMucCuaBan\Teamfight Tactics\Live"
> ```

Sau khi terminal hiển thị dòng chữ:
```text
=========================================================================
   HOAN TAT TOAN BO CAU HINH! HE THONG DA DUOC TOI UU CHO DTCL
=========================================================================
```
Toàn bộ hệ thống đã được đồng bộ chuẩn, bạn có thể mở game và trải nghiệm ngay!

---

### 🟡 Cách 3: Hướng dẫn tự cấu hình thủ công bằng tay

Nếu bạn muốn tự mình kiểm tra và chỉnh từng bước trên máy:

#### 1. Tối ưu phần mềm AMD Software: Adrenalin Edition
Card tích hợp AMD được quản lý bởi phần mềm này. Mở ứng dụng lên và chỉnh 2 mục sau:
1. **Tắt Overlay:** Vào biểu tượng **Bánh răng (Cài đặt)** góc trên bên phải $\rightarrow$ Tab **Preferences** $\rightarrow$ Gạt nút **In-Game Overlay** sang **Disabled (Tắt)**.
2. **Xóa Shader cũ:** Vào Tab **Gaming** $\rightarrow$ Mục **Graphics**:
   * Đặt **Graphics Profile** thành **Default (Tiêu chuẩn)**.
   * Tắt các mục: *Radeon Anti-Lag*, *Radeon Boost*, *Radeon Enhanced Sync*.
   * Cuộn xuống dưới cùng, nhấp vào dòng **Advanced** $\rightarrow$ tìm dòng **Reset Shader Cache** $\rightarrow$ bấm nút **Perform Reset**.

#### 2. Tăng thời gian chờ cho Windows (Chống đơ 2s)
1. Nhấn tổ hợp phím `Windows + X` $\rightarrow$ chọn **Terminal (Admin)** hoặc **PowerShell (Admin)**.
2. Dán 2 dòng lệnh sau vào rồi nhấn **Enter**:
   ```powershell
   Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "TdrDelay" -Value 30 -Type DWord
   Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "TdrDdiDelay" -Value 30 -Type DWord
   ```

#### 3. Ép bản ĐTCL chạy chế độ DirectX 11
1. Mở thư mục cài đặt ĐTCL: `BaseEngine.ini` (thường nằm tại `<Ổ đĩa cài game>\Riot Games\Teamfight Tactics\Live\Engine\Config\BaseEngine.ini`).
2. Mở file `BaseEngine.ini` bằng Notepad, tìm dòng `[/Script/WindowsTargetPlatform.WindowsTargetSettings]` và chèn thêm:
   ```ini
   DefaultGraphicsRHI=DefaultGraphicsRHI_DX11
   ```
3. Tìm tiếp dòng `[SystemSettings]` và chèn thêm:
   ```ini
   r.RHIName=D3D11
   r.D3D12.Enable=0
   ```
4. Lưu file lại. Giờ đây game sẽ luôn luôn khởi động bằng DirectX 11.

---

## 💡 MẸO HỮU ÍCH KHI CHƠI ĐTCL TRÊN CARD ONBOARD AMD

1. **Khi cắm 2 màn hình:**
   * Trong cài đặt hình ảnh của game, nên để chế độ **Toàn Màn Hình (Fullscreen)** thay vì Không Viền (Borderless) để card onboard không phải render đồng thời giao diện Desktop của Windows.
2. **Nếu dùng ứng dụng MetaTFT / Overwolf:**
   * Mở Cài đặt của **Overwolf** $\rightarrow$ Tắt mục **Hardware Acceleration (Tăng tốc phần cứng)** để ứng dụng này không tranh giành bộ nhớ render với card tích hợp.
3. **Bật chế độ cấu hình thấp trên Riot Client:**
   * Trong Riot Client / Liên Minh, bấm vào Bánh răng Cài đặt $\rightarrow$ Tích chọn **Bật chế độ cấu hình thấp (Low Spec Mode)** và **Đóng Client khi vào trận**. Điều này giúp giải phóng hơn 1.5 GB RAM cho card onboard xử lý combat cuối trận mượt mà hơn.

---

## 🤝 CHIA SẺ & ĐÓNG GÓP

Nếu cẩm nang và công cụ này giúp bạn giải quyết được tình trạng treo máy khó chịu bấy lâu nay:
* Đừng quên bấm **⭐ Star** trên góc phải kho lưu trữ GitHub này để lan tỏa giải pháp đến nhiều anh em game thủ khác nhé!
* Gặp bất kỳ lỗi nào khác, hãy gửi phản hồi tại mục [Issues](https://github.com/HTP8888/tft-anti-crash-optimizer/issues).

**Tác giả:** [HTP8888](https://github.com/HTP8888)  
**Bản quyền:** Mã nguồn mở theo giấy phép [MIT License](LICENSE) - Hoàn toàn miễn phí và an toàn cho cộng đồng.
