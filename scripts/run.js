const main = async () => {
   
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy("registIQ");
    await domainContract.deployed();
    console.log("Contract deployed to:", domainContract.address);
   
    //Pass in a second variable
    
    let txn = await domainContract.register("stubborngoat", {value: ethers.utils.parseEther('0.1')});
    await txn.wait();
  
    const address = await domainContract.getAddress("stubborngoat");
    console.log("Owner of domain stubborngoat:", address);

    const balance = await ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", ethers.utils.formatEther(balance));
    
  }
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();