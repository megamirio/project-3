
module.exports = {
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            gas: 50000000, // We know this is enough for this project, not necessarily your future projects
            network_id: "*" // Match any network id
        }
    }
};
