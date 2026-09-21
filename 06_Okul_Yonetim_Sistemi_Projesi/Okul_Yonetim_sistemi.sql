-- =============================================
-- OKUL YÖNETİM SİSTEMİ VERİTABANI PROJESİ
-- =============================================

-- 1. TABLOLARIN OLUŞTURULMASI

CREATE TABLE Bolumler (
    BolumId INT PRIMARY KEY IDENTITY(1,1),
    BolumAdi NVARCHAR(100) NOT NULL
);

CREATE TABLE Ogrenciler (
    OgrenciId INT PRIMARY KEY IDENTITY(1,1),
    Ad NVARCHAR(50) NOT NULL,
    Soyad NVARCHAR(50) NOT NULL,
    BolumId INT FOREIGN KEY REFERENCES Bolumler(BolumId),
    KayitTarihi DATE DEFAULT GETDATE(),
    Durum BIT DEFAULT 1
);

CREATE TABLE Dersler (
    DersId INT PRIMARY KEY IDENTITY(1,1),
    DersAdi NVARCHAR(100) NOT NULL,
    Kredi INT NOT NULL
);

CREATE TABLE Notlar (
    NotId INT PRIMARY KEY IDENTITY(1,1),
    OgrenciId INT FOREIGN KEY REFERENCES Ogrenciler(OgrenciId),
    DersId INT FOREIGN KEY REFERENCES Dersler(DersId),
    VizeNotu DECIMAL(5,2),
    FinalNotu DECIMAL(5,2),
    Ortalama DECIMAL(5,2)
);

-- 2. FONKSİYON (FUNCTION)
-- Vize (%40) ve Final (%60) hesaplayan fonksiyon
GO
CREATE FUNCTION fn_OrtalamaHesapla (
    @Vize DECIMAL(5,2),
    @Final DECIMAL(5,2)
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    RETURN (@Vize * 0.40) + (@Final * 0.60);
END;
GO

-- 3. TRIGGER (TETİKLEYİCİ)
-- Not girildiğinde ortalamayı otomatik hesaplayan trigger
CREATE TRIGGER trg_NotEkleGuncelle
ON Notlar
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE N
    SET N.Ortalama = dbo.fn_OrtalamaHesapla(i.VizeNotu, i.FinalNotu)
    FROM Notlar N
    INNER JOIN inserted i ON N.NotId = i.NotId;
END;
GO

-- 4. STORED PROCEDURE (PROSEDÜR)
-- Öğrencinin detaylı not karnesini getiren prosedür
CREATE PROCEDURE sp_OgrenciNotDokumu
    @OgrenciId INT
AS
BEGIN
    SELECT 
        o.Ad + ' ' + o.Soyad AS Ogrenci,
        b.BolumAdi,
        d.DersAdi,
        n.VizeNotu,
        n.FinalNotu,
        n.Ortalama
    FROM Ogrenciler o
    INNER JOIN Bolumler b ON o.BolumId = b.BolumId
    INNER JOIN Notlar n ON o.OgrenciId = n.OgrenciId
    INNER JOIN Dersler d ON n.DersId = d.DersId
    WHERE o.OgrenciId = @OgrenciId;
END;
GO
