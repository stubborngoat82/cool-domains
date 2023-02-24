import React, { useEffect, useState } from 'react';
import './styles/App.css';
import twitterLogo from './assets/twitter-logo.svg';
import logo from './assets/devil.svg';
import {ethers} from "ethers";
import contractAbi from './utils/contractABI.json';
import polygonLogo from './assets/polygonlogo.png';
import ethLogo from './assets/ethlogo.png';
import { networks } from '.utils/networks';


// Constants
const TWITTER_HANDLE = '_buildspace';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
//domain minting
const tld ='.hell';
const CONTRACT_ADDRESS = '0xa7dE076C216fA849BD23c4D81fB09e2d19B11196'

const App = () => {
        //Just a state variable we use to store our user's public wallet. Don't forget to           import useState at the top.
        const [currentAccount, setCurrentAccount] = useState('');
        //Add some  state data properties
        const [domain, setDomain] = useState('');
        const [loading, setLoading] = useState(false);
  const [record, setRecord] = useState('');

  const [network, setNetwork] = useState('');  
  
  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get Metamask -> https://metamask.io/");
        return;
      }
      const accounts = await ethereum.request({method: "eth_requestAccounts"});

      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]);
    } catch (error) {
      console.log(error)
    }
  }

    
      const checkIfWalletIsConnected = async () => {
      //First make sure whave access to window.ethereum
      const { ethereum } = window;

      if (!ethereum) {
        console.log('Make sure you have metamask!');
        return;
      } else {
        console.log('We have the ethereum object,', ethereum);
      }

      //check if authorized to access users wallet
      const accounts = await ethereum.request({ method: 'eth_accounts' });

      //Users can have multiple authorized accounts, we grab the first one if there
      if (accounts.length !==0) {
          const account = accounts[0];
          console.log('Found an authorized account:', account);
          setCurrentAccount(account);
        } else {
              console.log('No authorized account found');
        }

      const chainId = await ethereum.request({method: 'eth_chainId'});
      setNetwork(networks[chainId]);

      ethereum.on('chainChanged', handleChainChanged);

      //reload the page when the chain changes
      function handleChainChanged(_chainId) {
        window.location.reload();
      }
        
    };

  const mintDomain = async () => {
    //Dont run if domain is empty
    if (!domain) { return }
    //Alert the user is the domain is too short
    if (domain.length < 3) {
      alert('Domain must be at least 3 characters long');
      return;
    }

    //Calulates price based on length of domain (change this to match your contract)
    // 3 chars = 20 MATIC, 4 chars = 15 MATIC, 5 or more chars = 10 MATIC
    const price = domain.length === 3 ? '0.5' : domain.length === 4 ? '0.3' : '0.1';
    console.log("Minting domain", domain, "with price", price);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi.abi, signer);

            console.log("Going to pop wallet now to pay gas...")
      let tx = await contract.register(domain, {value: ethers.utils.parseEther(price)});
      //wait for the transaction to be mined
        const receipt = await tx.wait();

        //Check if the transaction was successfully completed
        if (receipt.status === 1) {
          console.log("Domain minted! https://mumbai.polygonscan.com/tx/"+tx.hash);

          //Set the record for the domain
          tx = await contract.setRecord(domain, record);
          await tx.wait();

          console.log("Record set! https://mumbai.polygonscan.com/tx/"+tx.hash);

          setRecord('');
          setDomain('');
        }
        else {
            alert("Transaction failed! Please try again.");
        }
      }
  }
    catch(error){
      console.log(error);
    }
  }    
  
  //Render methods
  //create a function to render if wallet is not connected yet
  const renderNotConnectedContainer = () => (
    <div className="connect-wallet-container">
      <img src="https://media.giphy.com/media/bt0awXL3z92tG/giphy.gif" alt="Devil GIF" />   
      <button onClick={connectWallet} className="cta-button conect-wallet-button">
        Connect Wallet
      </button>
    </div>
  );

//Form to enter domain name and data
  const renderInputForm = () => {
    return(
      <div className="form-container">
        <div className="first-row">
          <input
            type="text"
            value={domain}
            placeholder='domain'
            onChange={e => setDomain(e.target.value)}
            />
          <p className='tld'> {tld} </p>
        </div>
        
          <input
            type="text"
            value={record}
            placeholder='What scares you to death?'
            onChange={e => setRecord(e.target.value)}
          />

        <div className="button-container">
            <button className='cta-button mint-button' disabled={null} onClick={mintDomain}>
            Mint
            </button>
            <button className='cta-button mint-button' disabled={null} onClick={null}>
            Set Data
            </button>
        </div>
      </div>
    );
  }
  
  // This runs our functions when the page loads
  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);

  return (
		<div className="App">
			<div className="container">
				<div className="header-container">
                    <div className="left">
                        <div className="header-logo">
                            <img alt="Company Logo" className="company-logo" src={logo}/>
                        </div> 
                        <div className="header-text">
                            <p className="title">(dot).hell Name Service</p>
                            <p className="subtitle">Your immortal API on the blockchain!</p>
                        </div>
                    </div>
                </div>
	
                {/*render connect wallet if account is not connected*/}
                {!currentAccount && renderNotConnectedContainer()}
                {/*render input form if account is connected*/}
                {currentAccount && renderInputForm()}
        
                <div className="footer-container">
					<img alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
					<a
						className="footer-text"
						href={TWITTER_LINK}
						target="_blank"
						rel="noreferrer"
					>{`built with @${TWITTER_HANDLE}`}</a>
				</div>
			</div>
		</div>
  
	);
};

export default App;
