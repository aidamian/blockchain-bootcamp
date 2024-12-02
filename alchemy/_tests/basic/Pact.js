// Define an enum-like object for promise states
// This helps us avoid magic strings and makes the code easier to manage.
const PactState = Object.freeze({
  PENDING: 'pending', // Initial state, waiting to be resolved or rejected
  RESOLVED: 'resolved', // Promise has been resolved with a value
  REJECTED: 'rejected', // Promise has been rejected with a reason
});

class Pact {
  /**
   * The constructor takes an executor function as its argument.
   * The executor is called immediately with two functions: resolve and reject.
   * These functions allow the user to resolve or reject the promise.
   */
  constructor(executor) {
    // Initialize state as "pending" because the promise hasn't settled yet
    this.state = PactState.PENDING;

    // Initialize value to `undefined`, will be set when resolved or rejected
    this.value = undefined;

    // Arrays to store callbacks for when the promise resolves or rejects
    this.onResolves = []; // For `.then` callbacks
    this.onRejects = [];  // For `.catch` callbacks

    // Define the resolve function
    const resolve = (value) => {
      // Ensure that resolve can only be called once
      if (this.state !== PactState.PENDING) return;

      // Update state to "resolved" and store the resolved value
      this.state = PactState.RESOLVED;
      this.value = value;

      // Execute all `.then` callbacks with the resolved value
      for (const callback of this.onResolves) {
        callback(value);
      }
    };

    // Define the reject function
    const reject = (reason) => {
      // Ensure that reject can only be called once
      if (this.state !== PactState.PENDING) return;

      // Update state to "rejected" and store the rejection reason
      this.state = PactState.REJECTED;
      this.value = reason;

      // Execute all `.catch` callbacks with the rejection reason
      for (const callback of this.onRejects) {
        callback(reason);
      }
    };

    // Call the executor function with resolve and reject
    // Any errors in the executor should automatically reject the promise
    try {
      executor(resolve, reject);
    } catch (error) {
      reject(error); // If the executor throws, reject the promise
    }
  }

  /**
   * The `.then` method allows users to attach a callback that will be called
   * when the promise is resolved.
   * It returns a new `Pact` to enable chaining.
   */
  then(callback) {
    return new Pact((resolve, reject) => {
      const handleResolve = (value) => {
        try {
          // Call the user-provided callback with the resolved value
          const result = callback(value);

          // If the result is a `Pact` (or promise-like), chain it
          if (result instanceof Pact || (result && typeof result.then === 'function')) {
            result.then(resolve).catch(reject);
          } else {
            // Otherwise, resolve the new promise with the returned value
            resolve(result);
          }
        } catch (error) {
          // If the callback throws an error, reject the new promise
          reject(error);
        }
      };

      if (this.state === PactState.RESOLVED) {
        // If the promise is already resolved, execute the callback immediately
        handleResolve(this.value);
      } else if (this.state === PactState.PENDING) {
        // If the promise is still pending, store the callback for later
        this.onResolves.push(handleResolve);
      }
    });
  }

  /**
   * The `.catch` method allows users to attach a callback that will be called
   * when the promise is rejected.
   * It also returns a new `Pact` to enable chaining.
   */
  catch(callback) {
    return new Pact((resolve, reject) => {
      const handleReject = (reason) => {
        try {
          // Call the user-provided callback with the rejection reason
          const result = callback(reason);

          // If the result is a `Pact` (or promise-like), chain it
          if (result instanceof Pact || (result && typeof result.then === 'function')) {
            result.then(resolve).catch(reject);
          } else {
            // Otherwise, resolve the new promise with the returned value
            resolve(result);
          }
        } catch (error) {
          // If the callback throws an error, reject the new promise
          reject(error);
        }
      };

      if (this.state === PactState.REJECTED) {
        // If the promise is already rejected, execute the callback immediately
        handleReject(this.value);
      } else if (this.state === PactState.PENDING) {
        // If the promise is still pending, store the callback for later
        this.onRejects.push(handleReject);
      }
    });
  }
}

module.exports = Pact;
