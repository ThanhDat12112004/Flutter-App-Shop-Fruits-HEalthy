using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace API_DBFruits.Models;

public partial class DbfruitsContext : IdentityDbContext<User>
{
    public DbfruitsContext()
    {
    }

    public DbfruitsContext(DbContextOptions<DbfruitsContext> options)
        : base(options)
    {
    }


    public virtual DbSet<ChiTietDonHang> ChiTietDonHangs { get; set; }

    public virtual DbSet<GioHang> GioHangs { get; set; }

    public virtual DbSet<DanhMucSanPham> DanhMucSanPhams { get; set; }

    public virtual DbSet<DonHang> DonHangs { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<SanPham> SanPhams { get; set; }

    public virtual DbSet<DanhMucYeuThich> DanhMucYeuThiches { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=DESKTOP-8LB02MD;Database=DBFruits;Trusted_Connection=True;TrustServerCertificate=True;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.Entity<User>().Property(u => u.Initials).HasMaxLength(5);
        modelBuilder.HasDefaultSchema("identity");



        modelBuilder.Entity<ChiTietDonHang>(entity =>
        {
            entity.HasKey(e => e.ChiTietDonHangId).HasName("PK__ChiTietD__45B33F83BD38F376");
            entity.ToTable("ChiTietDonHang", tb => tb.HasTrigger("trg_UpdateStockAndTotal"));

            entity.Property(e => e.ChiTietDonHangId).HasColumnName("ChiTietDonHangID");
            entity.Property(e => e.DonHangId).HasColumnName("DonHangID");
            //entity.Property(e => e.GiaBan).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.SanPhamId).HasColumnName("SanPhamID");

            entity.HasOne(d => d.DonHang).WithMany(p => p.ChiTietDonHangs)
                .HasForeignKey(d => d.DonHangId)
                .HasConstraintName("FK__ChiTietDo__DonHa__440B1D61");

            entity.HasOne(d => d.SanPham).WithMany(p => p.ChiTietDonHangs)
                .HasForeignKey(d => d.SanPhamId)
                .HasConstraintName("FK__ChiTietDo__SanPh__44FF419A");
        });
        modelBuilder.Entity<DanhMucYeuThich>(entity =>
        {
            entity.HasKey(e => e.DanhMucYeuThichId).HasName("PK__DanhMucY__A1718DFEF6FCD0BB");

            entity.ToTable("DanhMucYeuThich");

            entity.Property(e => e.ThoiGian).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.KhachHang).WithMany(p => p.DanhMucYeuThiches)
                .HasForeignKey(d => d.KhachHangId)
                .HasConstraintName("FK__DanhMucYe__Khach__3F466844");

            entity.HasOne(d => d.SanPham).WithMany(p => p.DanhMucYeuThiches)
                .HasForeignKey(d => d.SanPhamId)
                .HasConstraintName("FK__DanhMucYe__SanPh__403A8C7D");
        });
        modelBuilder.Entity<GioHang>(entity =>
        {
            entity.HasKey(e => e.GioHangId).HasName("PK__GioHang__4242286DC5EAC7CC");

            entity.ToTable("GioHang");

            entity.Property(e => e.ThoiGian).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.KhachHang).WithMany(p => p.GioHangs)
                .HasForeignKey(d => d.KhachHangId)
                .HasConstraintName("FK__GioHang__KhachHa__4AB81AF0");

            entity.HasOne(d => d.SanPham).WithMany(p => p.GioHangs)
                .HasForeignKey(d => d.SanPhamId)
                .HasConstraintName("FK__GioHang__SanPham__4BAC3F29");
        });

        modelBuilder.Entity<DanhMucSanPham>(entity =>
        {
            entity.HasKey(e => e.DanhMucId).HasName("PK__DanhMucS__1C53BA7B6ABD4F38");

            entity.ToTable("DanhMucSanPham");

            entity.Property(e => e.DanhMucId).HasColumnName("DanhMucID");
            entity.Property(e => e.MoTa).HasMaxLength(255);
            entity.Property(e => e.TenDanhMuc).HasMaxLength(100);
        });

        modelBuilder.Entity<DonHang>(entity =>
        {
            entity.HasKey(e => e.DonHangId).HasName("PK__DonHang__D159F4DE94398C4A");

            entity.ToTable("DonHang");

            entity.Property(e => e.DonHangId).HasColumnName("DonHangID");
            entity.Property(e => e.KhachHangId).HasColumnName("KhachHangID");
            entity.Property(e => e.NgayDat).HasDefaultValueSql("(getdate())");
            //entity.Property(e => e.TongTien)
            //    .HasDefaultValue(0m)
            //    .HasColumnType("decimal(10, 2)");
            entity.Property(e => e.TrangThai)
                .HasMaxLength(50)
                .HasDefaultValue("Chưa xử lý");

            entity.HasOne(d => d.KhachHang).WithMany(p => p.DonHangs)
                .HasForeignKey(d => d.KhachHangId)
                .HasConstraintName("FK__DonHang__KhachHa__412EB0B6");
        });

        //modelBuilder.Entity<User>(entity =>
        //{
        //    entity.HasKey(e => e.Id).HasName("PK__KhachHan__880F211BA6AC4A33");

        //    entity.ToTable("KhachHang");

        //    entity.Property(e => e.Id).HasColumnName("KhachHangID");
        //    entity.Property(e => e.DiaChi).HasMaxLength(255);
        //    entity.Property(e => e.Email).HasMaxLength(100);
        //    entity.Property(e => e.PhoneNumber)
        //        .HasMaxLength(20)
        //        .IsUnicode(false);
        //    entity.Property(e => e.TenKhachHang).HasMaxLength(100);
        //});

        modelBuilder.Entity<SanPham>(entity =>
        {
            entity.HasKey(e => e.SanPhamId).HasName("PK__SanPham__05180FF402320268");

            entity.ToTable("SanPham");

            entity.Property(e => e.SanPhamId).HasColumnName("SanPhamID");
            entity.Property(e => e.AnhSanPham).HasMaxLength(255);
            entity.Property(e => e.DanhMucId).HasColumnName("DanhMucID");
            entity.Property(e => e.GiaBan).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.MoTa).HasMaxLength(255);
            entity.Property(e => e.TenSanPham).HasMaxLength(100);

            entity.HasOne(d => d.DanhMuc).WithMany(p => p.SanPhams)
                .HasForeignKey(d => d.DanhMucId)
                .HasConstraintName("FK__SanPham__DanhMuc__398D8EEE");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
