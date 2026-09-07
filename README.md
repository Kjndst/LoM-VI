# Lord of Mysteries - Quỷ Bí Chi Chủ Việt Hoá

Bản Việt Hoá dành cho **Lord of Mysteries**, được dịch trực tiếp từ **dữ liệu tiếng Trung của game**, không dịch vòng qua bản tiếng Anh.

Mục tiêu của LoM-VI là giữ đúng **lore, thuật ngữ và cách gọi quen thuộc của độc giả Quỷ Bí Chi Chủ**, đồng thời tối ưu bản dịch cho trải nghiệm thực tế trong game.

Hiện bản dịch đã phủ khoảng **99% nội dung có thể truy xuất từ data game**, bao gồm UI, hội thoại, nhiệm vụ, kỹ năng, vật phẩm, trang bị, mechanic và nhiều text runtime khác.

## Bản Việt Hoá có gì?

- Dịch trực tiếp từ source tiếng Trung của game.
- Ưu tiên thuật ngữ và cách gọi quen thuộc của cộng đồng Quỷ Bí Chi Chủ.
- Việt Hoá UI, hội thoại, nhiệm vụ, kỹ năng, vật phẩm, trang bị và phần lớn text gameplay.
- Tooltip skill/item/mechanic ưu tiên **đúng nghĩa và đủ thông tin để chơi, build và so sánh hiệu quả**.
- Tên skill, item và nhãn UI được rút gọn có chủ đích khi cần để hạn chế tràn chữ, chồng chữ và vỡ giao diện vốn được thiết kế cho chữ Trung ngắn hơn tiếng Việt.

LoM-VI không hướng tới kiểu dịch từng chữ hoặc dịch máy nguyên xi. UI và tên gọi ưu tiên ngắn, dễ nhận biết; hội thoại ưu tiên tự nhiên theo ngữ cảnh; mô tả gameplay ưu tiên độ chính xác.

## Data bản dịch lấy từ đâu?

Nguồn chính là **data tiếng Trung được trích trực tiếp từ game**, gồm các nhóm như StringDB, UI strings, skill, item/equipment, quest/dialogue, gameplay mechanic, StringConst và một số runtime text ngoài StringDB thông thường.

Dữ liệu sau khi trích xuất được đưa vào Translation Database để dịch, QC, thống nhất terminology và build thành payload cho patcher.

## Vietnamese Font - tùy chọn

Game gốc không phải lúc nào cũng có đầy đủ glyph tiếng Việt. Vì vậy LoM-VI cung cấp gói **Vietnamese Font** riêng để giúp dấu tiếng Việt hiển thị đầy đủ và đồng nhất hơn, tránh ký tự mất dấu, ô vuông hoặc fallback font không phù hợp.

Font Patch là **optional** và độc lập với Translation. Nếu font mặc định trên máy bạn đã hiển thị tiếng Việt tốt, có thể không cài gói này.

## Cài đặt

1. Tải **LoM-VI Patcher** mới nhất từ Releases.
2. Mở patcher và chọn thư mục Lord of Mysteries nếu chưa được tự nhận diện.
3. Cài **Vietnamese Translation**.
4. Cài thêm **Vietnamese Font** nếu cần.
5. Khởi động game bình thường.

### Stable hiện tại

- **Patcher:** `0.3.0`
- **Core:** `0.2.0.4`
- **Translation:** `2026.09.07.1`
- **Font:** `2026.09.05.1`

## Tương thích với English Patch

LoM-VI có cơ chế patch riêng và **không phụ thuộc vào English Patch**.

Khả năng cài đồng thời LoM-VI với English Patch hiện **chưa được kiểm thử chính thức**, vì vậy chưa thể đảm bảo hai bản patch không ghi đè hoặc xung đột runtime với nhau.

English Patch của **Lani** chỉ được tham khảo ở một số khía cạnh kỹ thuật và cơ chế localization/runtime. **Data và nội dung bản dịch LoM-VI không lấy từ English Patch.**

## Lưu ý

LoM-VI là dự án cộng đồng, không phải sản phẩm chính thức của nhà phát triển hoặc nhà phát hành Lord of Mysteries.

Game có thể được cập nhật bất kỳ lúc nào. Bản cập nhật mới có thể thêm text, đổi ID, thay đổi cấu trúc data, font hoặc resource và khiến một phần patch cần được cập nhật lại.

Con số **~99%** thể hiện mức độ bao phủ đối với data hiện có thể truy xuất và xử lý, không có nghĩa mọi màn hình trong mọi tình huống runtime đã được kiểm thử 100%.

Nếu gặp text tiếng Trung, lỗi font, sai nghĩa, vỡ UI hoặc mechanic không đúng, hãy gửi screenshot và vị trí xuất hiện để có thể đối chiếu chính xác.

## Credits

Cảm ơn **Lani / Lord of Mysteries English Patch** vì các tham khảo kỹ thuật liên quan tới localization và runtime text. English Patch không phải nguồn dịch của LoM-VI.

Toàn bộ tên game, nhân vật, hình ảnh và tài sản liên quan thuộc quyền sở hữu của các tác giả, nhà phát triển và nhà phát hành tương ứng.

**Đây là bản Việt Hoá miễn phí. From Linh Lan Bang with love.**

## Project status

Đợt phát triển hiện tại đã hoàn tất và dự án đang ở trạng thái **closed / maintenance-only**. Khi game thay đổi hoặc có lỗi mới được xác nhận, tiếp tục từ:

- [`docs/HANDOFF-2026-09-07-PROJECT-CLOSED.md`](docs/HANDOFF-2026-09-07-PROJECT-CLOSED.md) - mốc đóng dự án và authority mới nhất.
- [`docs/CURRENT_STATE.md`](docs/CURRENT_STATE.md) - lịch sử kỹ thuật chi tiết của các gate trước đó.
- [`docs/UPDATE_CONTRACT.md`](docs/UPDATE_CONTRACT.md) - component ownership và update/versioning contract.
- [`docs/ERROR_CODES.md`](docs/ERROR_CODES.md) - launcher/runtime error code reference.
