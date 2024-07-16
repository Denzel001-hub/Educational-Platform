module educational_platform::educational_platform {
    use sui::event;
    use sui::sui::SUI;
    use std::string::{String};
    use sui::coin::{Coin, value, split, put, take};
    use sui::object::{Self, UID, ID, new, uid_to_inner};
    use sui::balance::{Balance, zero};
    use sui::tx_context::{Self, TxContext, sender};
    use sui::table::{Self, Table};
    use sui::transfer;

    // Constants for error codes
    const Error_Invalid_Amount: u64 = 2;
    const Error_Insufficient_Payment: u64 = 4;
    const Error_Invalid_Price: u64 = 6;
    const Error_Invalid_Supply: u64 = 7;
    const Error_CourseNotListed: u64 = 8;
    const Error_Not_Enrolled: u64 = 9;
    const Error_Not_Owner: u64 = 0;

    // User struct definition
    public struct User has key {
        id: UID,
        `for`: ID,
        user_name: String,
        user_type: u8,
        public_key: String
    }

    // Course struct definition
    public struct Course has key, store {
        id: UID,
        course_id: ID,
        students: Table<address, bool>,
        name: String,
        details: String,
        price: u64,
        total_supply: u64,
        available: u64,
        creator: address,
        balance: Balance<SUI>,
    }

    public struct CourseCap has key {
        id: UID,
        `for`: ID
    }

    // EnrolledCourse struct definition
    public struct EnrolledCourse has key {
        id: UID,
        course_id: ID,
        student: address
    }

    // TutorProfile struct definition
    public struct TutorProfile has key {
        id: UID,
        tutor_name: String,
        subjects: vector<String>,
    }

    // TutoringService struct definition
    public struct TutoringService has key {
        id: UID,
        tutor_id: u64,
        subject_id: u64,
        rate: u64,
        available: bool,
    }

    // TutoringSession struct definition
    public struct TutoringSession has key {
        id: UID,
        tutor_id: u64,
        student: address,
        session_id: u64,
        completed: bool,
        rating: u8,
    }

    // Events Definitions

    // CourseCreated event
    public struct CourseCreated has copy, drop {
        course_id: ID,
        creator: address,
    }

    // CourseEnrolled event
    public struct CourseEnrolled has copy, drop {
        course_id: ID,
        student: address,
    }

    // CourseCompleted event
    public struct CourseCompleted has copy, drop {
        course_id: ID,
        student: address,
    }

    // CourseUpdated event
    public struct CourseUpdated has copy, drop {
        course_id: ID,
        new_details: String,
    }

    // CourseUnlisted event
    public struct CourseUnlisted has copy, drop {
        course_id: ID,
    }

    // FundWithdrawal event
    public struct FundWithdrawal has copy, drop {
        amount: u64,
        recipient: address,
    }

    // TutorProfileCreated event
    public struct TutorProfileCreated has copy, drop {
        tutor_id: u64,
        tutor_name: String,
    }

    // TutoringServiceOffered event
    public struct TutoringServiceOffered has copy, drop {
        tutor_id: u64,
        subject_id: u64,
        rate: u64,
    }

    // TutoringSessionRequested event
    public struct TutoringSessionRequested has copy, drop {
        session_id: u64,
        tutor_id: u64,
        student: address,
    }

    // TutoringSessionCompleted event
    public struct TutoringSessionCompleted has copy, drop {
        session_id: u64,
        tutor_id: u64,
        student: address,
    }

    // TutoringServiceUpdated event
    public struct TutoringServiceUpdated has copy, drop {
        tutor_id: u64,
        subject_id: u64,
        rate: u64,
        available: bool,
    }

    // Function to register a new user
    public fun register_user(
        user_name: String,  // Username encoded as UTF-8 bytes
        user_type: u8,          // Type of user (e.g., student, tutor)
        public_key: String, // Public key of the user
        ctx: &mut TxContext     // Transaction context
    ) : User {
        User {  // Store user details
            id: new(ctx),
            `for`: sender(ctx),
            user_name: user_name,
            user_type: user_type,
            public_key: public_key,
        }
    }

    // Function to create a new course
    public fun create_course(
        creator: address,       // Address of the course creator
        name: String,       // Course name encoded as UTF-8 bytes
        details: String,    // Course details encoded as UTF-8 bytes
        price: u64,             // Price of the course
        supply: u64,            // Total supply of the course
        ctx: &mut TxContext     // Transaction context
    ) {
        assert!(price > 0, Error_Invalid_Price);  // Validate price is positive
        assert!(supply > 0, Error_Invalid_Supply);  // Validate supply is positive

        let course_uid = new(ctx);  // Generate unique ID for the course
        let inner = uid_to_inner(&course_uid);
        let course = Course {  // Create new course object
            id: course_uid,
            course_id: inner,  // Initial course ID (to be updated)
            students: Table::new(ctx),
            name: name,
            details: details,
            price: price,
            total_supply: supply,
            available: supply,
            creator: creator,
            balance: zero<SUI>(),  // Initialize balance for course
        };

        let cap = CourseCap {
            id: new(ctx),
            `for`: inner
        };
        transfer::transfer(cap, sender(ctx));
        transfer::share_object(course);  // Store course details
        event::emit(CourseCreated {  // Emit CourseCreated event
            course_id: inner,  // Placeholder for actual course ID
            creator: creator,
        });
    }

    // Function to enroll a student in a course
    public fun enroll_in_course(
        course: &mut Course,     // Reference to the course to enroll in
        payment_coin: Coin<SUI>,  // Payment coin for enrollment
        ctx: &mut TxContext      // Transaction context
    ) {
        assert!(table::contains(&course.students, ctx.sender()), Error_Not_Enrolled);
        assert!(course.available > 0, Error_Invalid_Supply);  // Ensure course has available seats
        assert!(value(&payment_coin) >= course.price, Error_Insufficient_Payment);  // Ensure payment is sufficient
        let student = ctx.sender();
        let total_price = course.price;  // Get total price of the course

        course.available = course.available - 1;  // Decrease available seats
        let paid = split(payment_coin, total_price, ctx);  // Split payment
        put(&mut course.balance, paid);  // Add payment to course balance
        table::insert(&mut course.students, student, true);

        let enrolled_course_uid = new(ctx);  // Generate unique ID for enrolled course
        transfer::transfer(EnrolledCourse {  // Transfer enrollment details
            id: enrolled_course_uid,
            course_id: course.course_id,
            student: student,
        }, student);

        event::emit(CourseEnrolled {  // Emit CourseEnrolled event
            course_id: course.course_id,
            student: student,
        });

        if (course.available == 0) {  // If no seats available, unlist course
            event::emit(CourseUnlisted {
                course_id: course.course_id,
            });
        }
    }

    // Function to mark a course as completed by a student
    public fun complete_course(
        enrolled_course: &EnrolledCourse,  // Reference to the enrolled course
        ctx: &mut TxContext  // Transaction context
    ) {
        assert!(enrolled_course.student == ctx.sender(), Error_Not_Enrolled);  // Ensure sender is enrolled student

        event::emit(CourseCompleted {  // Emit CourseCompleted event
            course_id: enrolled_course.course_id,
            student: ctx.sender(),
        });
    }

    // Function to update details of a course
    public fun update_course_details(
        cap: &CourseCap,          // Admin Capability
        course: &mut Course,     // Reference to the course to update
        new_details: String, // New course details encoded as UTF-8 bytes
        _ctx: &mut TxContext     // Transaction context
    ) {
        assert!(uid_to_inner(&course.id) == cap.`for`, Error_Not_Owner);
        let details_str = new_details;  // Convert bytes to string
        course.details = details_str;  // Update course details

        event::emit(CourseUpdated {  // Emit CourseUpdated event
            course_id: course.course_id,
            new_details: details_str,
        });
    }

    // Function to withdraw funds from a course's balance
    public fun withdraw_funds(
        cap: &CourseCap,          // Admin Capability
        course: &mut Course,     // Reference to the course to withdraw funds from
        amount: u64,             // Amount to withdraw
        recipient: address,      // Address of the recipient
        ctx: &mut TxContext      // Transaction context
    ) {
        assert!(uid_to_inner(&course.id) == cap.`for`, Error_Not_Owner);

        let take_coin = take(&mut course.balance, amount, ctx);  // Take funds from course balance
        transfer::public_transfer(take_coin, recipient);  // Transfer funds to recipient

        event::emit(FundWithdrawal {  // Emit FundWithdrawal event
            amount: amount,
            recipient: recipient,
        });
    }

    // Function to create a tutor profile
    public fun create_tutor_profile(
        tutor_name: String,  // Tutor name encoded as UTF-8 bytes
        subjects: vector<String>,  // Subjects taught by the tutor
        ctx: &mut TxContext      // Transaction context
    ) {
        let tutor_uid = new(ctx);  // Generate unique ID for the tutor
        transfer::share_object(TutorProfile {  // Store tutor profile details
            id: tutor_uid,
            tutor_name: tutor_name,
            subjects: subjects,
        });

        event::emit(TutorProfileCreated {  // Emit TutorProfileCreated event
            tutor_id: uid_to_inner(&tutor_uid),
            tutor_name: tutor_name,
        });
    }

    // Function to offer a tutoring service
    public fun offer_tutoring_service(
        tutor_id: u64,           // ID of the tutor offering the service
        subject_id: u64,         // ID of the subject for the tutoring service
        rate: u64,               // Rate charged for the tutoring service
        ctx: &mut TxContext      // Transaction context
    ) {
        let tutoring_service_uid = new(ctx);  // Generate unique ID for tutoring service
        transfer::share_object(TutoringService {  // Store tutoring service details
            id: tutoring_service_uid,
            tutor_id: tutor_id,
            subject_id: subject_id,
            rate: rate,
            available: true,
        });

        event::emit(TutoringServiceOffered {  // Emit TutoringServiceOffered event
            tutor_id: tutor_id,
            subject_id: subject_id,
            rate: rate,
        });
    }

    // Function to request a tutoring session
    public fun request_tutoring(
        tutor_id: u64,           // ID of the tutor for the tutoring session
        student: address,        // Address of the student requesting the session
        ctx: &mut TxContext      // Transaction context
    ) {
        let session_uid = new(ctx);  // Generate unique ID for tutoring session
        transfer::share_object(TutoringSession {  // Store tutoring session details
            id: session_uid,
            tutor_id: tutor_id,
            student: student,
            session_id: uid_to_inner(&session_uid),
            completed: false,
            rating: 0,
        });

        event::emit(TutoringSessionRequested {  // Emit TutoringSessionRequested event
            session_id: uid_to_inner(&session_uid),
            tutor_id: tutor_id,
            student: student,
        });
    }

    // Function to complete a tutoring session
    public fun complete_tutoring(
        session: &mut TutoringSession,  // Reference to the tutoring session to complete
        rating: u8,                    // Rating given for the tutoring session
        _ctx: &mut TxContext           // Transaction context
    ) {
        session.completed = true;  // Mark session as completed
        session.rating = rating;   // Assign rating to session

        event::emit(TutoringSessionCompleted {  // Emit TutoringSessionCompleted event
            session_id: session.session_id,
            tutor_id: session.tutor_id,
            student: session.student,
        });
    }

    // Function to update a tutoring service
    public fun update_tutoring_service(
        service: &mut TutoringService,  // Reference to the tutoring service to update
        new_rate: u64,                  // New rate for the tutoring service
        available: bool,                // Availability status of the tutoring service
        _ctx: &mut TxContext            // Transaction context
    ) {
        service.rate = new_rate;        // Update rate of the tutoring service
        service.available = available;  // Update availability status

        event::emit(TutoringServiceUpdated {  // Emit TutoringServiceUpdated event
            tutor_id: service.tutor_id,
            subject_id: service.subject_id,
            rate: new_rate,
            available: available,
        });
    }

    // Function to get details of a course
    public fun get_course_details(course: &Course) : (ID, String, String, u64, u64, address) {
        (
            course.course_id,
            course.name,
            course.details,
            course.price,
            course.total_supply,
            course.creator,
        )
    }

    // Function to get details of an enrolled course
    public fun get_enrolled_course_details(enrolled_course: &EnrolledCourse) : (ID, address) {
        (
            enrolled_course.course_id,
            enrolled_course.student,
        )
    }

    // Function to update the student of an enrolled course
    public fun update_enrolled_course_student(enrolled_course: &mut EnrolledCourse, student: address) {
        enrolled_course.student = student;  // Update student of enrolled course
    }
}
