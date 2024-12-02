

const { faker } = require("@faker-js/faker");

const username = process.env.LOGNAME || process.env.USER || "user";
const hostname = process.env.HOSTNAME || process.env.NAME || "localhost";

console.log(`Using ${username} on ${hostname}`);


const name = faker.person.fullName();
const message = `Hello, ${name}!`;
console.log(message);