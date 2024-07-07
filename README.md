## Sui Move Library for Educational Services

Welcome to the Sui Move Library for Educational Services! This library is purpose-built to power an advanced educational platform on the Sui blockchain. It offers foundational structures to efficiently manage users, courses, and tutoring services. Packed with powerful functionalities, it aims to:

### User Management
- **Registering Users**: Register new users with attributes like username, user type, and public key.

### Course Management
- **Creating Courses**: Create new courses with details such as name, description, price, and total supply.
- **Enrolling in Courses**: Enroll students in listed courses by handling payment and seat availability.
- **Completing Courses**: Mark courses as completed by students.
- **Updating Course Details**: Update the details of an existing course.
- **Withdrawing Funds**: Withdraw funds from a course's balance to a specified recipient.

### Tutor Management
- **Creating Tutor Profiles**: Create tutor profiles with information like tutor name and subjects taught.
- **Offering Tutoring Services**: Offer tutoring services with specified rates and subjects.
- **Requesting Tutoring Sessions**: Request tutoring sessions from tutors.
- **Completing Tutoring Sessions**: Mark tutoring sessions as completed and assign ratings.
- **Updating Tutoring Services**: Update the rate and availability status of tutoring services.

### Events
- **CourseCreated**: Emitted when a new course is created.
- **CourseEnrolled**: Emitted when a student enrolls in a course.
- **CourseCompleted**: Emitted when a student completes a course.
- **CourseUpdated**: Emitted when course details are updated.
- **CourseUnlisted**: Emitted when a course is unlisted.
- **FundWithdrawal**: Emitted when funds are withdrawn from a course.
- **TutorProfileCreated**: Emitted when a new tutor profile is created.
- **TutoringServiceOffered**: Emitted when a new tutoring service is offered.
- **TutoringSessionRequested**: Emitted when a tutoring session is requested.
- **TutoringSessionCompleted**: Emitted when a tutoring session is completed.
- **TutoringServiceUpdated**: Emitted when a tutoring service is updated.

### Key Features
- **Secure and transparent educational platform on the Sui blockchain.**
- **Management of users, courses, and tutoring services with comprehensive event handling.**
- **Efficient enrollment and payment handling for courses.**
- **Capability to update course and tutoring service details.**
- **Ability to withdraw funds from courses.**

### Usage
This library can be integrated into your Sui Move projects to implement a secure and decentralized educational platform. You can use the provided functions to manage users, create and update courses, enroll in courses, complete courses, and handle tutoring services.

### Functions Overview

#### Registering Users

public fun register_user(
    user_name: String,  
    user_type: u8,         
    public_key: String, 
    ctx: &mut TxContext     
)

- Registers a new user with the provided username, user type, and public key.

#### Creating Courses

public fun create_course(
    creator: address,       
    name: String,       
    details: String,    
    price: u64,             
    supply: u64,            
    ctx: &mut TxContext     
)

- Creates a new course with the specified details, price, and supply.

#### Enrolling in Courses

public fun enroll_in_course(
    course: &mut Course,     
    student: address,        
    payment_coin: &mut Coin<SUI>,  
    ctx: &mut TxContext      
)

- Enrolls a student in a course, handling payment and seat availability.

#### Completing Courses

public fun complete_course(
    enrolled_course: &EnrolledCourse,  
    student: address,  
    ctx: &mut TxContext  
)

- Marks a course as completed by the enrolled student.

#### Updating Course Details

public fun update_course_details(
    course: &mut Course,     
    new_details: String, 
    _ctx: &mut TxContext     
)

- Updates the details of an existing course.

#### Withdrawing Funds

public fun withdraw_funds(
    course: &mut Course,     
    amount: u64,             
    recipient: address,      
    ctx: &mut TxContext      
)

- Withdraws funds from a course's balance to the specified recipient.

#### Creating Tutor Profiles

public fun create_tutor_profile(
    tutor_name: String,  
    subjects: vector<String>,  
    ctx: &mut TxContext      
)

- Creates a new tutor profile with the specified name and subjects.

#### Offering Tutoring Services

public fun offer_tutoring_service(
    tutor_id: u64,           
    subject_id: u64,         
    rate: u64,               
    ctx: &mut TxContext      
)

- Offers a new tutoring service with the specified rate and subject.

#### Requesting Tutoring Sessions

public fun request_tutoring(
    tutor_id: u64,           
    student: address,        
    ctx: &mut TxContext      
)

- Requests a new tutoring session with the specified tutor.

#### Completing Tutoring Sessions

public fun complete_tutoring(
    session: &mut TutoringSession,  
    rating: u8,                    
    _ctx: &mut TxContext           
)

- Marks a tutoring session as completed and assigns a rating.

#### Updating Tutoring Services

public fun update_tutoring_service(
    service: &mut TutoringService,  
    new_rate: u64,                  
    available: bool,                
    _ctx: &mut TxContext            
)

- Updates the rate and availability status of a tutoring service.

#### Retrieving Course Details

public fun get_course_details(course: &Course) : (u64, String, String, u64, u64, bool, address)

- Retrieves details of a specified course.

#### Retrieving Enrolled Course Details

public fun get_enrolled_course_details(enrolled_course: &EnrolledCourse) : (u64, address)

- Retrieves details of an enrolled course.

#### Updating Enrolled Course Student

public fun update_enrolled_course_student(enrolled_course: &mut EnrolledCourse, student: address)

- Updates the student of an enrolled course.

### Conclusion
This educational platform provides a comprehensive solution for managing users, courses, and tutoring services on the Sui blockchain. It leverages the features of Sui Move to ensure secure and efficient operations. Integrate this library into your Sui Move projects to create a robust and decentralized educational system.
