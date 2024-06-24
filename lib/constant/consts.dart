final RegExp EMAIL_VALIDATION_REGEX =
    RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

final RegExp PASSWORD_VALIDATION_REGEX =
    RegExp(r"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$");

final RegExp NAME_VALIDATION_REGEX = RegExp(r"\b([A-ZÀ-ÿ][-,a-z. ']+[ ]*)+");

final String PLACEHOLDER_PFP =
    "https://images.unsplash.com/photo-1575936123452-b67c3203c357?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
