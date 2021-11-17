# DevOps Repository

This Repository contains all files pertaining to local DevOps management. Currently, this includes:

1. docker-compose.yml
    * Builds images amattsonsm/flights-api, users-api, and bookings-api on separate ports using a .env file.
    * .env file must contain definitions for: 
        * spring.datasource.url
        * spring.datasource.username
        * spring.datasource.password
