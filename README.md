# TFT Anti-Crash & Windows 11 Game Optimizer (AMD Vega / Ryzen Edition)

Bộ công cụ và tài liệu khắc phục triệt để hiện tượng **treo đơ máy, đứng hình (Freeze / Hang / Crash)** khi chơi **Đấu Trường Chân Lý (TFT Standalone)** và **Liên Minh Huyền Thoại (LoL)** trên Windows 11 và đồ họa AMD Radeon.

---

## 1. Bối cảnh & Hiện tượng (Symptoms)

* **Phần cứng:** Laptop/PC sử dụng CPU AMD Ryzen (ví dụ: Ryzen 7 5800H) tích hợp đồ họa **AMD Radeon Graphics (Vega 8)**, RAM 16GB, chạy **Windows 11 (23H2)** với thiết lập **2 màn hình (Dual Monitors)**.
* **Hiện tượng:**
  * Vào trận ĐTCL hoặc chuyển cảnh tải trận thì game bị đứng hình, chuột đơ hoặc toàn bộ Windows bị treo cứng.
  * Phải giữ nút nguồn để tắt máy hoặc đợi rất lâu mới văng lỗi.

---

## 2. Phân tích nguyên nhân gốc rễ từ tệp Nhật ký (Root Cause Analysis)

Qua điều tra chuyên sâu các tệp nhật ký trận đấu (`TFT.log`, `r3dlog.txt`, `__sentry-event`), nhóm kỹ thuật đã phát hiện **3 nguyên nhân cốt lõi**:

### A. TFT Standalone (Unreal Engine 5) tự ép chạy DirectX 12 lỗi trên GPU AMD
* Phiên bản ĐTCL mới độc lập được xây dựng trên động cơ **Unreal Engine 5**. Mặc định, game cố gắng khởi chạy với **DirectX 12 RHI (`LogD3D12RHI`)**.
* Trên kiến trúc đồ họa AMD Radeon Vega (GCN 5), bộ biên dịch Shader D3D12 kết hợp cùng Agility SDK của Unreal Engine bị lỗi tạo Pipeline State Object (PSO):
  ```text
  LogD3D12RHI: Error: Failed to create pipeline state with combined hash ..., error 887a0005.
  LogD3D12RHI: Error: GPU crash detected: Device 0 Removed: DXGI_ERROR_DEVICE_HUNG
  ```
* Hậu quả: GPU bị đơ cứng hoàn toàn (`DEVICE_HUNG`). Đây cũng là lý do Riot Games ra thông báo khuyến nghị người chơi sử dụng **DirectX 11 (Feature Level 4.3) và Shader Model 5**.

### B. Thời gian chờ phát hiện treo đồ họa mặc định của Windows quá ngắn (TdrDelay = 2s)
* Windows có cơ chế **TDR (Timeout Detection and Recovery)**. Nếu card đồ họa không phản hồi trong vòng **2 giây**, Windows sẽ tự động kết luận GPU đã chết và gửi lệnh ngắt / khởi động lại driver card màn hình.
* Khi game tải tài nguyên trận đấu trên 2 màn hình, thời gian dựng lại tài nguyên có thể chạm mốc 2.66s. Khi vượt quá 2s, Windows lập tức cưỡng chế ngắt card, gây ra crash game.

### C. Xung đột Overlay và Tiến trình ngầm (MetaTFT / Overwolf, AMD Overlay, BlueStacks)
* **Overwolf / MetaTFT** và **AMD In-Game Overlay** đồng thời chèn lớp phủ hook vào luồng render DirectX 11/12 của game, cạnh tranh với trình bảo mật **Riot Vanguard**.
* Các máy ảo chạy ngầm (BlueStacks 4 tiến trình, Docker Desktop, WSL) chiếm dụng tới 12GB RAM, đẩy dung lượng khả dụng xuống còn 4GB và gây nghẽn ngắt tài nguyên hệ thống (DPC Latency Spikes).

---

## 3. Các giải pháp đã triển khai (Implemented Solutions)

1. **Khóa cứng chế độ DirectX 11 cho Unreal Engine TFT:**
   * Cấu hình trực tiếp vào `BaseEngine.ini` của bộ cài game:
     ```ini
     [/Script/WindowsTargetPlatform.WindowsTargetSettings]
     DefaultGraphicsRHI=DefaultGraphicsRHI_DX11

     [SystemSettings]
     r.RHIName=D3D11
     r.D3D12.Enable=0
     ```
   * Cập nhật `Engine.ini` trong `%LOCALAPPDATA%\TFT\Saved\Config\WindowsClient\` và đặt cờ **Read-Only** để game không tự ý đảo ngược về DirectX 12.
2. **Nâng thời gian chờ TDR của Windows lên 30 giây:**
   * Tăng `TdrDelay` và `TdrDdiDelay` trong Registry `HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers` từ 2 giây lên **30 giây**. Card đồ họa có dư dả thời gian load trận mà không bị Windows ép ngắt.
3. **Vô hiệu hóa Fullscreen Optimizations của Windows 11:**
   * Gắn cờ tương thích `~ DISABLEDXMAXIMIZEDWINDOWEDMODE HIGHDPIAWARE` cho `TFTClient-Win64-Shipping.exe` và `League of Legends.exe`.
4. **Tối ưu cài đặt AMD Software: Adrenalin:**
   * Tắt **In-Game Overlay**.
   * Xóa sạch bộ nhớ đệm Shader lỗi cũ (`DxcCache` & `DxCache`).
   * Tắt các tính năng can thiệp trễ: Anti-Lag, Boost, Enhanced Sync.
5. **Xây dựng công cụ 1-Click (`ToiUu_ChoiGame.bat`):**
   * Tự động dọn dẹp RAM, tắt máy ảo BlueStacks/WSL, xóa cache shader AMD và kích hoạt các thiết lập tối ưu chỉ với 1 cú nhấp chuột.

---

## 4. Hướng dẫn sử dụng công cụ

1. Tải về hoặc nhân bản kho lưu trữ:
   ```bash
   git clone https://github.com/<your-username>/tft-anti-crash-optimizer.git
   ```
2. Nhấp chuột phải vào tệp `ToiUu_ChoiGame.bat` $\rightarrow$ chọn **Run as Administrator** (hoặc nhấp đúp nếu dùng Shortcut ngoài Desktop).
3. Đợi 3-5 giây để công cụ tự động hoàn tất.
4. Mở Riot Client và trải nghiệm game mượt mà!

---

## Giấy phép
Mã nguồn phát hành theo giấy phép [MIT](LICENSE).
