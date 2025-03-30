using Microsoft.EntityFrameworkCore.Migrations;

namespace API_DBFruits.Migrations
{
    public partial class AddUpdateStockAndTotalTrigger : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
            CREATE TRIGGER trg_UpdateStockAndTotal
            ON ChiTietDonHang
            AFTER INSERT
            AS
            BEGIN
                UPDATE SanPham
                SET SoLuongTon = SoLuongTon - i.SoLuong
                FROM SanPham s
                INNER JOIN inserted i ON s.SanPhamID = i.SanPhamID;

                UPDATE ChiTietDonHang
                SET GiaBan = s.GiaBan * c.SoLuong
                FROM ChiTietDonHang c
                INNER JOIN inserted i ON c.ChiTietDonHangID = i.ChiTietDonHangID
                INNER JOIN SanPham s ON s.SanPhamID = i.SanPhamID;

                UPDATE DonHang
                SET TongTien = (
                    SELECT SUM(c.GiaBan) 
                    FROM ChiTietDonHang c
                    WHERE c.DonHangID = @DonHangID
                )
                WHERE DonHangID = @DonHangID;
            END");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP TRIGGER trg_UpdateStockAndTotal");
        }
    }
}
