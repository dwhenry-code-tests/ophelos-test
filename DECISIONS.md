# Ophelos technical test

The below outline the initial plan for the implementation.

## Planned implementation

- [X] Add create user auth endpoint to create user and return JWT token (see Notes Authentification)
- [X] Add login endpoint to return a new JWT token
- [X] Endpoint to create I & E statements (see Notes API Definition)
- [ ] Endpoint to retrieval I & E statements (see Notes API Definition)

## Notes

### Authenification

I plan to use JWT token for auth within the actual application.

In the real system the actual user creation and auth (to get a new JWT token) would be a separate service, due to time I will not
fully implement this here and have the login endpoint ONLY require teh user email address. In a live system I would likely user
`Devise` for the password login (would still use JWT in the API endpoints).

## API Definition

The following is the initial thoughts on how teh API will be structured

- POST '/v1/statements' (create a new statement for the current year for the login in user)
  - Fields:
      - incomes:
        - name:
        - amount:
      - expenditures:
        - name:
        - amount:
  - Response:
    - total_income:
    - total_expenditure:
    - disposable_income:
    - ie_rating:
- (Note planning to implement) POST '/v1/statements/[year]' (create a new statement for the given year for the login in user)
- GET '/v1/statements' (return all statements for the user)
  - response:
    - statements: (Array)
      - year:
      - total_income:
      - total_expenditure:
      - disposable_income:
      - ie_rating:
    - pagination:
      - page:
      - total_pages:
      - next_page: (optional)
      - prev_page: (optional)
- GET '/v1/statements/[year]' (return the statement for requested year)
  - response:
    - year:
    - total_income:
    - total_expenditure:
    - disposable_income:
    - ie_rating:


## Other considerations

### Should the rails application be API only?

I did consider this and it would give some speed benefits, however as this is a technical test I choose to leave the full impelemnattion in (in case you ask for a web page in the follow up questions).

### Authentication in the API

Ideally the JWT token would be in the headers as this more secure and also simplify the message passing, however as this a test application I will instead put the token in the request/response body as this is easier to test.

### Storing amount in the DB

I have stored all amounts as decimals to avoid rounding issues that you can otherwise see when using floats. This is accuming that all incomes and expenditures are in whole pennies.

### Type of Disposable Income

In the DB it is always a Decimal, but when I return it this result in it should as a string. In order to avoid this I have converted it to a float when output. The other option would be to report it in whole pence values instead. At this stage I have just left as a float in the output.

## Next steps

The following is a list of things that could be added to make the system work better:

**Code cleanup**
* Use FactoryBot to create fixtures
* extract API auth logic to a separate module so it wasn't in the controller

**Code extension**
* Look at creating users with multiple years of data
* Sharing the statements a user has created with a validated third party
* more tests, have only covered the main case in what I have here - add a tool like `SimpleCov` to help identify any branches without tests

