/* =========================================================
   RACE DAY DATABASE
   Part 1 - Section C: Database & SQL
   ========================================================= */

-- Create database if it does not already exist
IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

/* =========================================================
   DROP EXISTING TABLES
   Allows the script to be run again without table conflicts
   ========================================================= */

IF OBJECT_ID('dbo.Result', 'U') IS NOT NULL
    DROP TABLE dbo.Result;

IF OBJECT_ID('dbo.Enrollment', 'U') IS NOT NULL
    DROP TABLE dbo.Enrollment;

IF OBJECT_ID('dbo.Category', 'U') IS NOT NULL
    DROP TABLE dbo.Category;

IF OBJECT_ID('dbo.Event', 'U') IS NOT NULL
    DROP TABLE dbo.Event;

IF OBJECT_ID('dbo.Organizer', 'U') IS NOT NULL
    DROP TABLE dbo.Organizer;

IF OBJECT_ID('dbo.Participant', 'U') IS NOT NULL
    DROP TABLE dbo.Participant;

IF OBJECT_ID('dbo.[User]', 'U') IS NOT NULL
    DROP TABLE dbo.[User];

GO

/* =========================================================
   1. USER
   ========================================================= */

CREATE TABLE dbo.[User]
(
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    PhoneNumber NVARCHAR(20) NOT NULL,
    Role NVARCHAR(20) NOT NULL,

    ProfileImageUrl NVARCHAR(500) NULL,

    CONSTRAINT CK_User_Role
        CHECK (Role IN ('Organizer', 'Participant'))
);

GO

/* =========================================================
   2. ORGANIZER
   ========================================================= */

CREATE TABLE dbo.Organizer
(
    OrganizerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,

    CONSTRAINT FK_Organizer_User
        FOREIGN KEY (UserID)
        REFERENCES dbo.[User](UserID)
);

GO

/* =========================================================
   3. PARTICIPANT
   ========================================================= */

CREATE TABLE dbo.Participant
(
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,

    CONSTRAINT FK_Participant_User
        FOREIGN KEY (UserID)
        REFERENCES dbo.[User](UserID)
);

GO

/* =========================================================
   4. EVENT
   ========================================================= */

CREATE TABLE dbo.Event
(
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganizerID INT NOT NULL,

    Name NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    EventDate DATE NOT NULL,
    Location NVARCHAR(150) NOT NULL,
    Distance NVARCHAR(50) NOT NULL,
    EventType NVARCHAR(20) NOT NULL,

    BannerImageUrl NVARCHAR(500) NULL,

    CONSTRAINT FK_Event_Organizer
        FOREIGN KEY (OrganizerID)
        REFERENCES dbo.Organizer(OrganizerID),

    CONSTRAINT CK_Event_Type
        CHECK (EventType IN ('Run', 'Walk', 'Cycle'))
);

GO

/* =========================================================
   5. CATEGORY
   ========================================================= */

CREATE TABLE dbo.Category
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,

    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NOT NULL,

    CONSTRAINT FK_Category_Event
        FOREIGN KEY (EventID)
        REFERENCES dbo.Event(EventID)
);

GO

/* =========================================================
   6. ENROLLMENT
   ========================================================= */

CREATE TABLE dbo.Enrollment
(
    EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,

    EnrollmentDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',

    CONSTRAINT FK_Enrollment_Participant
        FOREIGN KEY (ParticipantID)
        REFERENCES dbo.Participant(ParticipantID),

    CONSTRAINT FK_Enrollment_Event
        FOREIGN KEY (EventID)
        REFERENCES dbo.Event(EventID),

    CONSTRAINT FK_Enrollment_Category
        FOREIGN KEY (CategoryID)
        REFERENCES dbo.Category(CategoryID),

    CONSTRAINT CK_Enrollment_Status
        CHECK (Status IN ('Pending', 'Confirmed', 'Completed', 'Cancelled')),

    CONSTRAINT UQ_Enrollment_Participant_Event
        UNIQUE (ParticipantID, EventID)
);

GO

/* =========================================================
   7. RESULT
   ========================================================= */

CREATE TABLE dbo.Result
(
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrollmentID INT NOT NULL UNIQUE,

    FinishTime TIME NOT NULL,
    FinishingPosition INT NOT NULL,

    CONSTRAINT FK_Result_Enrollment
        FOREIGN KEY (EnrollmentID)
        REFERENCES dbo.Enrollment(EnrollmentID),

    CONSTRAINT CK_Result_Position
        CHECK (FinishingPosition > 0)
);

GO

/* =========================================================
   SAMPLE DATA
   ========================================================= */

/* -------------------------
   USERS
   ------------------------- */

INSERT INTO dbo.[User]
    (FirstName, LastName, Email, PasswordHash, PhoneNumber, Role)
VALUES
    ('Thabo', 'Mokoena', 'thabo.mokoena@example.com',
     'HASHED_PASSWORD_001', '0712345678', 'Organizer'),

    ('Lerato', 'Molefe', 'lerato.molefe@example.com',
     'HASHED_PASSWORD_002', '0723456789', 'Organizer'),

    ('Karabo', 'Nkosi', 'karabo.nkosi@example.com',
     'HASHED_PASSWORD_003', '0734567890', 'Participant'),

    ('Naledi', 'Mahlangu', 'naledi.mahlangu@example.com',
     'HASHED_PASSWORD_004', '0745678901', 'Participant');

GO

/* -------------------------
   ORGANIZERS
   ------------------------- */

INSERT INTO dbo.Organizer (UserID)
VALUES
    (1),
    (2);

GO

/* -------------------------
   PARTICIPANTS
   ------------------------- */

INSERT INTO dbo.Participant (UserID)
VALUES
    (3),
    (4);

GO

/* -------------------------
   EVENTS
   ------------------------- */

INSERT INTO dbo.Event
    (OrganizerID, Name, Description, EventDate, Location, Distance, EventType)
VALUES
    (1,
     'Pretoria City Run',
     'Annual road running event through Pretoria.',
     '2026-10-10',
     'Pretoria',
     '10 km',
     'Run'),

    (1,
     'Johannesburg Charity Walk',
     'Community walking event supporting local charities.',
     '2026-11-07',
     'Johannesburg',
     '5 km',
     'Walk'),

    (2,
     'Limpopo Cycle Challenge',
     'Road cycling challenge for amateur and experienced cyclists.',
     '2026-11-21',
     'Polokwane',
     '50 km',
     'Cycle');

GO

/* -------------------------
   CATEGORIES
   ------------------------- */

INSERT INTO dbo.Category
    (EventID, Name, Description)
VALUES
    (1, 'Open 10 km', '10 km category for all eligible participants.'),
    (1, 'Under 18', '10 km category for participants under 18.'),

    (2, 'Open 5 km', '5 km walking category for adults.'),
    (2, 'Family Walk', '5 km category suitable for families.'),

    (3, 'Open 50 km', '50 km cycling category for adult cyclists.'),
    (3, 'Under 18', '50 km cycling category for younger cyclists.');

GO

/* -------------------------
   ENROLLMENTS
   ------------------------- */

INSERT INTO dbo.Enrollment
    (ParticipantID, EventID, CategoryID, Status)
VALUES
    (1, 1, 1, 'Confirmed'),
    (2, 1, 1, 'Confirmed'),
    (1, 2, 3, 'Confirmed'),
    (2, 3, 5, 'Confirmed');

GO

/* -------------------------
   RESULTS
   ------------------------- */

INSERT INTO dbo.Result
    (EnrollmentID, FinishTime, FinishingPosition)
VALUES
    (1, '00:52:34', 1),
    (2, '00:57:12', 2);

GO

/* =========================================================
   CHECK THE CREATED TABLES
   ========================================================= */

SELECT * FROM dbo.[User];
SELECT * FROM dbo.Organizer;
SELECT * FROM dbo.Participant;
SELECT * FROM dbo.Event;
SELECT * FROM dbo.Category;
SELECT * FROM dbo.Enrollment;
SELECT * FROM dbo.Result;

GO

USE RaceDayDB;
GO

-- Check that all 7 tables exist
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Check sample data
SELECT * FROM dbo.[User];
SELECT * FROM dbo.Organizer;
SELECT * FROM dbo.Participant;
SELECT * FROM dbo.Event;
SELECT * FROM dbo.Category;
SELECT * FROM dbo.Enrollment;
SELECT * FROM dbo.Result;