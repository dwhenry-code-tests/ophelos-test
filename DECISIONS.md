# Ophelos technical test

The below outline the initial plan for the implementation.

## Planned implementation

- [X] Add create user auth endpoint to create user and return JWT token (see Notes Authentification)
- [ ] Add login endpoint to return a new JWT token
- [ ] Endpoint to create/retrieval of I & E statements (see Notes API Definition)

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

## Implementation steps

### Add quality gems

Add rspec

## Other considerations

### Should the rails application be API only?

I did consider this and it would give some speed benefits, however as this is a technical test I choose to leave the full impelemnattion in (in case you ask for a web page in the follow up questions).