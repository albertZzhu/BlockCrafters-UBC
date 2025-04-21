const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CrowdfundingManager", function () {
    let app;
    let appOwner;
    let founder1, founder2;
    let backer1, backer2;

    // for CFDToken test, CFDToken.sol?
    //   let cfdTokenAddress;       

    // Project parameters
    const projectName = "BlockCrafters";
    const projectGoal = ethers.parseEther("10");
    const oneEther = ethers.parseEther("1");
    const halfEther = ethers.parseEther("0.5");
    const descCID =    'Description. Should be 46b Hash.'+'-'.repeat(14);
    const photoCID =   'photoCID Should be 46b Hash.'+'-'.repeat(18);
    // const XdotComCID = 'XdotComCID__ Should be 46b Hash.';
    const socialMediaLinkCID = 'SocialMedia. Should be 46b Hash.'+'-'.repeat(14);
    let projectContract;
    let fundingDeadline;
    let milestoneDeadline;
    const oneDay = 86400;

    const tokenName = "BCR";
    const tokenSymbol = 'XdotComCID Should be 46b Hash.'+'-'.repeat(16);

    async function createValidProject(founder) {
        const tx = await app.connect(founder).createProject(
            projectName, fundingDeadline,
            descCID, photoCID, socialMediaLinkCID,
            tokenName, tokenSymbol
        );
    
        const receipt = await tx.wait();
        // Iterate over all logs to find the event you're interested in
        let projectCreatedEvent;
        for (const log of receipt.logs) {
        try {
            const parsedLog = app.interface.parseLog(log);
            if (parsedLog.name === "ProjectCreated") {
            projectCreatedEvent = parsedLog;
            break;
            }
        } catch (e) {
            // This log doesn't match any event in the ABI, ignore it.
        }
        }

        if (!projectCreatedEvent) {
        throw new Error("ProjectCreated event not found in logs");
        }
        const args = projectCreatedEvent.args;
        const projectAddress = args[0]; 
        return { tx,  projectAddress};
    }


    beforeEach(async function () {
        [appOwner, founder1, founder2, backer1, backer2] = await ethers.getSigners();

        // Current time + 1 day in seconds
        
        fundingDeadline = Math.floor(Date.now() / 1000) + oneDay;
        milestoneDeadline = fundingDeadline + oneDay;
        
        let addressProviderFactory = await ethers.getContractFactory("AddressProvider", appOwner);
        let addressProvider = await addressProviderFactory.deploy();
        
        let votingManagerFactory = await ethers.getContractFactory("ProjectVotingManager", appOwner);
        let votingManager = await upgrades.deployProxy(
            votingManagerFactory, [addressProvider.target], { initializer: 'initialize' }
        );
        await addressProvider.connect(appOwner).setProjectVotingManager(votingManager.target);
        
        let tokenManagerFactory = await ethers.getContractFactory("TokenManager", appOwner);
        let tokenManager = await upgrades.deployProxy(
            tokenManagerFactory, [addressProvider.target], { initializer: 'initialize' }
        );
        await addressProvider.connect(appOwner).setTokenManager(tokenManager.target);


        let appFactory = await ethers.getContractFactory("CrowdfundingManager", appOwner);
        app = await upgrades.deployProxy(
            appFactory, [addressProvider.target], { initializer: 'initialize' }
        );
        await addressProvider.connect(appOwner).setCrowdfundingManager(app.target);
        // console.log("app address", await addressProvider.getCrowdfundingManager());
        // console.log("votingManager address", await addressProvider.getProjectVotingManager());
        // console.log("tokenManager address", await addressProvider.getTokenManager());

        //  // Deploy ProjectToken logic contract
        // ProjectTokenFactory = await ethers.getContractFactory("ProjectToken");
        // ProjectToken = await ProjectTokenFactory.deploy("Temp", "TMP", appOwner.address); 

    });

    describe("Deployment", function () {
        it("Should set the correct platform platformOwner", async function () {
            expect(await app.platformOwner()).to.equal(appOwner.address);
        });

    });

    describe("Project creation", function () {
        it("Should create a project with correct parameters", async function () {
            // No project yet
            expect(await app.projectCount()).to.equal(0);

            // create a project
            const {tx, projectAddress} = await createValidProject(founder1)
            expect(tx)
                .to.emit(app, "ProjectCreated")
                .withArgs(projectAddress, founder1.address, fundingDeadline, descCID, photoCID, socialMediaLinkCID);

            // check project count increased
            expect(await app.projectCount()).to.equal(1);

            // Get project details
            const project = await ethers.getContractAt("CrowdfundingProject", projectAddress);
            // Verify project details
            expect(await project.founder()).to.equal(founder1.address);
            expect(await project.getProjectFundingGoal()).to.equal(0);
            expect(await project.fundingBalance()).to.equal(0);
            expect(await project.status()).to.equal(0); // ProjectStatus.Inactive = 0
            expect(await project.fundingDeadline()).to.equal(fundingDeadline);
            expect(await project.descCID()).to.equal(descCID);
            expect(await project.photoCID()).to.equal(photoCID);
            expect(await project.socialMediaLinkCID()).to.equal(socialMediaLinkCID);

        });

        it("Should revert if deadline is in the past", async function () {
            const pastDeadline = Math.floor(Date.now() / 1000) - 100000; // Past timestamp

            await expect(app.connect(founder1).createProject(
                projectName, pastDeadline,
                descCID, photoCID, socialMediaLinkCID,
                tokenName, tokenSymbol
            )).to.be.revertedWith("Deadline must be in the future");
        });
        it("Should revert if project name is empty or exceeds 100 characters", async function () {
            await expect(
                app.connect(founder1).createProject(
                    "", fundingDeadline,
                    descCID, photoCID, socialMediaLinkCID,
                    tokenName, tokenSymbol)
            ).to.be.revertedWith("Project name length must be between 1 and 100 characters");

            await expect(
                app.connect(founder1).createProject(
                    "a".repeat(200), fundingDeadline,
                    descCID, photoCID, socialMediaLinkCID,
                    tokenName, tokenSymbol)
            ).to.be.revertedWith("Project name length must be between 1 and 100 characters");
            // valid project names
            app.connect(founder1).createProject(
                "a".repeat(1), fundingDeadline,
                descCID, photoCID, socialMediaLinkCID,
                tokenName, tokenSymbol
            );
            app.connect(founder1).createProject(
                "a".repeat(100), fundingDeadline,
                descCID, photoCID, socialMediaLinkCID,
                tokenName, tokenSymbol
            )
        });
        it("Should revert if any IPFS has a wrong format", async function () {
            // TODO: checks only the length now, should check the format
            for(const x of [0,200]){
                await expect(
                    app.connect(founder1).createProject(
                        projectName, fundingDeadline,
                        "a".repeat(x), photoCID, socialMediaLinkCID,
                        tokenName, tokenSymbol)
                ).to.be.revertedWith("Invalid IPFS hash");
                await expect(
                    app.connect(founder1).createProject(
                        projectName, fundingDeadline,
                        descCID, "a".repeat(x), socialMediaLinkCID,
                        tokenName, tokenSymbol)
                ).to.be.revertedWith("Invalid IPFS hash");
                await expect(
                    app.connect(founder1).createProject(
                        projectName, fundingDeadline,
                        descCID, photoCID, "a".repeat(x),
                        tokenName, tokenSymbol)
                ).to.be.revertedWith("Invalid IPFS hash");
            }
        });
      
        it("Should record multiple projects for a founder in the founders mapping", async function () {
            // founder1 creates two projects
              const {projectAddress:project1Address, tx:tx1} = await createValidProject(founder1)
              
              await expect(tx1).to.emit(app, "ProjectCreated").withArgs(
                  project1Address,
                  founder1.address, fundingDeadline,
                  descCID, photoCID, socialMediaLinkCID,
                  tokenName, tokenSymbol
              );
              
              const {projectAddress:project2Address, tx:tx2} = await createValidProject(founder1)
              await expect(tx2).to.emit(app, "ProjectCreated").withArgs(
                  project2Address,
                  founder1.address, fundingDeadline,
                  descCID, photoCID, socialMediaLinkCID,
                  tokenName, tokenSymbol
              );
  
              // check projects mapping has two projects
              expect(await app.projectCount()).to.equal(2);
  
              // check founders mapping 
              const projects = await app.getFounderProjects(founder1.address);
              expect(projects.length).to.equal(2);
              expect(projects[0]).to.equal(project1Address);
              expect(projects[1]).to.equal(project2Address);
        });
    });
    describe("Adding Milestones", function () {
        let project1, project2;
        beforeEach(async function () {
            // each founder creates a project
            const {tx: tx1, projectAddress:project1Address} = await createValidProject(founder1)
            const {tx: tx2, projectAddress:project2Address} = await createValidProject(founder1)
            project1 = await ethers.getContractAt("CrowdfundingProject", project1Address);
            project2 = await ethers.getContractAt("CrowdfundingProject", project2Address);
        });
        it("Should add a milestone with correct parameters", async function () {
            await expect(project1.connect(founder1).addMilestone(
                "Milestone 1", // name (string)
                descCID, // description (string)
                oneEther, // fundingGoal (uint256)
                milestoneDeadline // deadline (uint256)
            ))
                .to.emit(project1, "MilestoneAdded")
                .withArgs(1, "Milestone 1", descCID, oneEther, milestoneDeadline);

        });
        it("Project should be updated with the correct funding goal", async function () {
            await project1.connect(founder1).addMilestone("Milestone 1",descCID,oneEther,milestoneDeadline)
            expect(await project1.getProjectFundingGoal()).to.equal(oneEther);
        });
        // it("Should revert if the project doesn't exist", async function () {
        //     let address;
        //     let project = await ethers.getContractAt("CrowdfundingProject", address);
            
        //     await expect(
        //         project.connect(founder1).addMilestone("Milestone 1",descCID,oneEther,milestoneDeadline)
        //     ).to.be.revertedWith("Project does not exist");
        // });
        it("Should revert if the project doesn't belong to the msg.sender", async function () {
            await expect(
                project1.connect(founder2).addMilestone("Milestone 1",descCID,oneEther,milestoneDeadline)
            ).to.be.revertedWith("Only the founder can perform this action");
        });
        it("Should revert if milestone Goal is not a positive number", async function () {
            await expect(
                project1.connect(founder1).addMilestone("Milestone 1",descCID,ethers.parseEther("0"),milestoneDeadline)
            ).to.be.revertedWith("Milestone goal must be positive");
        });
        it("Should revert if deadline is in the past", async function () {
            const pastDeadline = Math.floor(Date.now() / 10000) - 10000; // Past timestamp
            await expect(
                project1.connect(founder1).addMilestone("Milestone 1",descCID, oneEther, pastDeadline)
            ).to.be.revertedWith("Deadline must be in the future");
        });
        it("Should revert if milestone deadline is before previous milestone", async function () {
            await project1.connect(founder1).addMilestone("Milestone 1",descCID,oneEther,milestoneDeadline);
            await expect(
                project1.connect(founder1).addMilestone("Milestone 2",descCID,oneEther,milestoneDeadline-1000)
            ).to.be.revertedWith("Milestone deadline must be after the previous milestone");
        });
    });
    describe("Start Project Funding", function () {
        let project1;
        beforeEach(async function () {
            // each founder creates a project
            const {tx: tx1, projectAddress:project1Address} = await createValidProject(founder1)
            project1 = await ethers.getContractAt("CrowdfundingProject", project1Address);
            await project1.connect(founder1).addMilestone("Milestone 1", descCID, oneEther, milestoneDeadline);
        });
        it("Founder can start funding for a project", async function () {
            expect(await project1.connect(founder1).startFunding())
                .to.emit(project1, "ProjectStatusUpdated")
                .withArgs(1, 0);
        });
        // it("Should revert if the project doesn't exist", async function () {
        //     await expect(
        //         project1.connect(founder1).startFunding(10)
        //     ).to.be.revertedWith("Project does not exist");
        // });
        it("Should revert if the project is already active", async function () {
            await project1.connect(founder1).startFunding();
            await project1.connect(backer1).invest({ value: oneEther });
            await expect(
                project1.connect(founder1).startFunding()
            ).to.be.revertedWith("Can only start funding if project is inactive");
        });
        it("Should revert if the project is already funding", async function () {
            await project1.connect(founder1).startFunding();
            await expect(
                project1.connect(founder1).startFunding()
            ).to.be.revertedWith("Can only start funding if project is inactive");
        });
        it("Should revert if the project doesn't belong to the msg.sender", async function () {
            await expect(
                project1.connect(founder2).startFunding()
            ).to.be.revertedWith("Only the founder can perform this action");
        });
    });

    describe("Project investment", function () {
        let project1, tokenManager, tokenInstance;
        beforeEach(async function () {
            // each founder creates a project
            const {tx: tx1, projectAddress:project1Address} = await createValidProject(founder1)
            project1 = await ethers.getContractAt("CrowdfundingProject", project1Address);
            await project1.connect(founder1).addMilestone("Milestone 1", descCID, oneEther, milestoneDeadline);
            await project1.connect(founder1).startFunding();

            const tokenManagerAddress = await project1.tokenManager();
            tokenManager = await ethers.getContractAt("TokenManager", tokenManagerAddress);

            const tokenAddress = await project1.getTokenAddress();
            tokenInstance = await ethers.getContractAt("ProjectToken", tokenAddress);
        });

        it("Should allow invest to an funding project", async function () {
            expect(await tokenInstance.balanceOf(backer1.address)).to.equal(0);
            
            await expect(project1.connect(backer1).invest({ value: oneEther }))
                .to.emit(project1, "InvestmentMade")
                .withArgs(backer1.address, oneEther);

            // check project funded amount
            expect(await project1.fundingBalance()).to.equal(oneEther);
            // check token has minted to investor
            // TODO: After integrat with price feed the exchange is not 1:1
            const investorTokenBalance = await tokenInstance.balanceOf(backer1.address);
            expect(investorTokenBalance).to.equal(oneEther);
        });

        it("Should allow multiple investments from the same backer", async function () {
            expect(await tokenInstance.balanceOf(backer1.address)).to.equal(0);

            await project1.connect(backer1).invest({ value: halfEther });
            await project1.connect(backer1).invest({ value: halfEther });

            // check project funded amount
            expect(await project1.fundingBalance()).to.equal(ethers.parseEther("1"));
            const investorTokenBalance = await tokenInstance.balanceOf(backer1.address);
            expect(investorTokenBalance).to.equal(oneEther);
        });

        it("Should revert if project is not funding", async function () {
            // create and add milestone but not start funding
            const {tx:tx, projectAddress:projectAddress} = await createValidProject(founder2);
            let project2 = await ethers.getContractAt("CrowdfundingProject", projectAddress);
            await expect(
                project2.connect(backer1).invest({ value: oneEther })
            ).to.be.revertedWith("Project is not funding");
        });
        it("Should not allow investment after funding deadline", async function () {
            // Create a project with a short funding deadline
            let block = await ethers.provider.getBlock("latest");
            const shortDeadline = block.timestamp + 10; // 10 seconds from now
            tx = await app.connect(founder2).createProject(
                projectName, shortDeadline,
                descCID, photoCID, socialMediaLinkCID,
                tokenName, tokenSymbol
            );
            const receipt = await tx.wait();

            // Iterate over all logs to find the event you're interested in
            let projectCreatedEvent;
            for (const log of receipt.logs) {
            try {
                const parsedLog = app.interface.parseLog(log);
                if (parsedLog.name === "ProjectCreated") {
                projectCreatedEvent = parsedLog;
                break;
                }
            } catch (e) {
                // This log doesn't match any event in the ABI, ignore it.
            }
            }

            if (!projectCreatedEvent) {
            throw new Error("ProjectCreated event not found in logs");
            }

            const args = projectCreatedEvent.args;
            const projectAddress = args[0]; 
            
            let project2 = await ethers.getContractAt("CrowdfundingProject", projectAddress);
            await project2.connect(founder2).addMilestone("Milestone 1", descCID, oneEther, block.timestamp + 1000);
            await project2.connect(founder2).startFunding();
            await ethers.provider.send("evm_increaseTime", [500]); // Increase time by 20 seconds
            await ethers.provider.send("evm_mine"); // Mine a new block

            // Attempt to invest after the deadline
            await expect(
            project2.connect(backer1).invest({ value: oneEther })
            ).to.be.revertedWith("Expired project");
        });
        it("Should end funding and activate project if goal is reached", async function () {
            await project1.connect(backer1).invest({ value: oneEther });
            // check project status changed to Approved
            expect(await project1.status()).to.equal(2); // ProjectStatus.Active
        });
        it("Should revert if investment is larger than the remaining funding goal", async function () {
            await expect(
                project1.connect(backer1).invest({ value: projectGoal + oneEther })
            ).to.be.revertedWith("Investment exceeds funding goal");
        });
        it("Should revert if project goal is already reached", async function () {
            await project1.connect(backer1).invest({ value: oneEther });
            await expect(
                project1.connect(backer1).invest({ value: oneEther })
            ).to.be.revertedWith("Project is not funding");
        });
    });

    describe("Refund", function () {
        let project1, votingPlatform1;
        const fundingGoal = oneEther;
        let frozen = fundingGoal; // 100% frozen at the beginning
        let project1Address;
        beforeEach(async function () {
            // create a project
            const {tx: tx1, projectAddress:_project1address} = await createValidProject(founder1)
            project1Address = _project1address;            
            project1 = await ethers.getContractAt("CrowdfundingProject", project1Address);
            // add milestone
            await project1.connect(founder1).addMilestone("Milestone 1", descCID, halfEther, milestoneDeadline);
            await project1.connect(founder1).addMilestone("Milestone 2", descCID, halfEther, milestoneDeadline + oneDay);
            // fund to full
            await project1.connect(founder1).startFunding();
            await expect(project1.connect(backer1).invest({ value: fundingGoal }))
            .to.emit(project1, "InvestmentMade")
                .withArgs(backer1.address, fundingGoal);
        });
        it("Should allow backer to request refund if project failed (Ended)", async function () {
            //end project
            expect(await project1.getStatus()).to.equal(2); // ProjectStatus.Active
            await project1.connect(founder1).endProject();
            expect(await project1.getStatus()).to.equal(3); // ProjectStatus.Failed
            const prevBackerBalance = await ethers.provider.getBalance(backer1.address);
            const prevProjectBalance = await ethers.provider.getBalance(project1Address);
            let tokenManager = await ethers.getContractAt("TokenManager", await project1.tokenManager());
            const getRefundableAmount = await tokenManager.getRefundableAmount(project1Address,backer1.address);
            expect(getRefundableAmount).to.equal(halfEther*BigInt(20)/BigInt(100)+halfEther); // 0.2 ether
            let tx = await project1.connect(backer1).refund();
            receipt = await tx.wait();
            const gasUsed = receipt.gasUsed * receipt.gasPrice;
            // console.log(receipt.logs)
            const currBackerBalance = await ethers.provider.getBalance(backer1.address);
            const currProjectBalance = await ethers.provider.getBalance(project1Address);
            expect(currProjectBalance).to.be.equal(prevProjectBalance-getRefundableAmount); // 0.2 ether
            expect(currBackerBalance).to.be.equal(prevBackerBalance+getRefundableAmount-gasUsed);
        });
        it("Backers should be able to refund 20% of the funding if project fails the last milestone", async function () {
            //m1 vote
            await project1.connect(founder1).requestAdvance();
            expect(await project1.getCurrentMilestone()).to.equal(0);
            let votingPlatform1 = await ethers.getContractAt("ProjectVoting", await project1.votingPlatform());
            await votingPlatform1.connect(backer1).vote(0, true);
            expect(await project1.getCurrentMilestone()).to.equal(1);
            await project1.connect(founder1).endProject();
            expect(await project1.getStatus()).to.equal(3); // ProjectStatus.Failed
            const prevBackerBalance = await ethers.provider.getBalance(backer1.address);
            const prevProjectBalance = await ethers.provider.getBalance(project1Address);
            let tokenManager = await ethers.getContractAt("TokenManager", await project1.tokenManager());
            const getRefundableAmount = await tokenManager.getRefundableAmount(project1Address,backer1.address);
            expect(getRefundableAmount).to.equal(oneEther*BigInt(20)/BigInt(100)); // 0.2 ether
            let tx = await project1.connect(backer1).refund();
            receipt = await tx.wait();
            const gasUsed = receipt.gasUsed * receipt.gasPrice;
            // console.log(receipt.logs)
            const currBackerBalance = await ethers.provider.getBalance(backer1.address);
            const currProjectBalance = await ethers.provider.getBalance(project1Address);
            expect(currProjectBalance).to.be.equal(prevProjectBalance-getRefundableAmount); // 0.2 ether
            expect(currBackerBalance).to.be.equal(prevBackerBalance+getRefundableAmount-gasUsed);
        });
    });

    describe("Fund withdrawal", function () {
        let project1, votingPlatform1;
        const fundingGoal = oneEther;
        let frozen = fundingGoal; // 100% frozen at the beginning
        let project1Address;
        before(async function () {
            // create a project
            const {tx: tx1, projectAddress:_project1address} = await createValidProject(founder1)
            project1Address = _project1address;            
            project1 = await ethers.getContractAt("CrowdfundingProject", project1Address);
            // add milestone
            await project1.connect(founder1).addMilestone("Milestone 1", descCID, halfEther, milestoneDeadline);
            await project1.connect(founder1).addMilestone("Milestone 2", descCID, halfEther, milestoneDeadline + oneDay);
            // fund to full
            await project1.connect(founder1).startFunding();
            const tx = await project1.connect(backer1).invest({ value: fundingGoal })
            await tx.wait();
            // ethers.provider.send("evm_mine", []); // Mine a new block
            await expect(tx)
            .to.emit(project1, "InvestmentMade")
                .withArgs(backer1.address, fundingGoal);
                
                // prepare voting
                votingPlatform1 = await ethers.getContractAt("ProjectVoting", await project1.votingPlatform());
        });
        it("non-founder should not be able to withdraw funds", async function () {
            // non-founder withdraws funds
            await expect(
                project1.connect(backer1).withdraw()
            ).to.be.revertedWith("Only the founder can perform this action");
        });
        it("Should allow Founder to self-invest and withdraw", async function () {
            const {tx: tx2, projectAddress:_project2Address} = await createValidProject(founder1)
            let project2 = await ethers.getContractAt("CrowdfundingProject", _project2Address);
            await project2.connect(founder1).addMilestone("Milestone 1", descCID, fundingGoal, milestoneDeadline);
            await project2.connect(founder1).startFunding();
            await project2.connect(founder1).invest({ value: fundingGoal });
            const prevFounderBalance = await ethers.provider.getBalance(founder1.address);
            const withdrawable = fundingGoal * BigInt(80) / BigInt(100); // 80% release = 0.4
            const transactionFee = withdrawable * BigInt(1) / BigInt(100); // 1% fee
            const founderShare = withdrawable - transactionFee;
            let tx = await project2.connect(founder1).withdraw();
            let receipt = await tx.wait();
            const gasUsed = receipt.gasUsed * receipt.gasPrice;
            // check the balance of the project
            // expect(await ethers.provider.getBalance(project1Address)).to.equal(0); // 0
            // check the balance of the founder
            const currFounderBalance = await ethers.provider.getBalance(founder1.address);
            expect(currFounderBalance).to.be.equal(prevFounderBalance-gasUsed+founderShare)

        });
        it("Should allow founder to withdraw Milestone1's 80% after project activated", async function () {
            expect(await project1.getBalance()).to.equal(fundingGoal);
            let prevFounderBalance = await ethers.provider.getBalance(founder1.address);
            let prevOwnerBalance = await ethers.provider.getBalance(appOwner.address);
            
            // milestone 1
            let releasing = halfEther * BigInt(80) / BigInt(100); // 80% release = 0.4
            frozen -= releasing; // milestone1*20%+mileston2*100% frozen = 0.6
            let transactionFee = releasing * BigInt(1) / BigInt(100); // 1% fee
            let founderShare = releasing - transactionFee;

            let withdrawTx = await project1.connect(founder1).withdraw();// withdraw 80% of milestone1 = 0.4 ether
            let receipt = await withdrawTx.wait();
            let gasUsed = receipt.gasUsed * receipt.gasPrice;

            expect(await project1.frozenFund()).to.equal(frozen); // 0.1
            expect(await project1.getBalance()).to.equal(frozen); // 0.6

            // platformOwner receives txn fee
            let currOwnerBalance = await ethers.provider.getBalance(appOwner.address);
            expect(currOwnerBalance - prevOwnerBalance).to.equal(transactionFee);

            // founder received their share (minus gas costs)
            let currFounderBalance = await ethers.provider.getBalance(founder1.address);
            expect(currFounderBalance - prevFounderBalance + gasUsed).to.equal(founderShare);
            
        });
        it("Should not allow founder to withdraw when no funds available (frozen)", async function () {
            it("Should revert if no funds available", async function () {
                await expect(
                    project1.connect(founder1).withdraw()
                ).to.be.revertedWith("No funds available for withdrawal");
            });
        });
        it("Should allow founder to withdraw Milestone2 funds after milestone advance request approved", async function () {
            //m1 vote
            await project1.connect(founder1).requestAdvance();
            expect(await project1.getCurrentMilestone()).to.equal(0);
            
            await votingPlatform1.connect(backer1).vote(0, true);
            expect(await project1.getCurrentMilestone()).to.equal(1);
            
            // m2 unfrozen
            let releasing = halfEther * BigInt(80) / BigInt(100); // 80% release = 0.4
            frozen -= releasing; // milestone1*20%+mileston2*100% frozen = 0.6
            let transactionFee = releasing * BigInt(1) / BigInt(100); // 1% fee
            let founderShare = releasing - transactionFee;
            
            prevFounderBalance = await ethers.provider.getBalance(founder1.address);
            prevOwnerBalance = await ethers.provider.getBalance(appOwner.address);

            withdrawTx = await project1.connect(founder1).withdraw();
            receipt = await withdrawTx.wait();
            gasUsed = receipt.gasUsed * receipt.gasPrice;

            // check frozen, and balance
            expect(await project1.getFrozenFunding()).to.equal(frozen); //0.2
            expect(await project1.getBalance()).to.equal(frozen);
            expect(await ethers.provider.getBalance(project1Address)).to.equal(frozen); //0.2
            
            // platformOwner receives txn fee
            currOwnerBalance = await ethers.provider.getBalance(appOwner.address);
            expect(currOwnerBalance - prevOwnerBalance).to.equal(transactionFee);

            // founder received their share (minus gas costs)
            currFounderBalance = await ethers.provider.getBalance(founder1.address);
            expect(currFounderBalance - prevFounderBalance + gasUsed).to.equal(founderShare);

        });
        
        it("Should allow founder to withdraw remaining funds after project completion", async function () {
            expect(await project1.getCurrentMilestone()).to.equal(1);
            await project1.connect(founder1).requestAdvance();
            await votingPlatform1.connect(backer1).vote(1, true);
            expect(await project1.getCurrentMilestone()).to.equal(1);

            expect(await project1.getStatus()).to.equal(4); // ProjectStatus.Completed
            // m2 unfrozen
            let releasing = fundingGoal * BigInt(20) / BigInt(100); // 80% release = 0.4
            frozen -= releasing; // milestone1*20%+mileston2*100% frozen = 0.6
            let transactionFee = releasing * BigInt(1) / BigInt(100); // 1% fee
            let founderShare = releasing - transactionFee;
            
            prevFounderBalance = await ethers.provider.getBalance(founder1.address);
            prevOwnerBalance = await ethers.provider.getBalance(appOwner.address);

            withdrawTx = await project1.connect(founder1).withdraw();
            receipt = await withdrawTx.wait();
            gasUsed = receipt.gasUsed * receipt.gasPrice;

            // check frozen, and balance
            expect(await project1.getFrozenFunding()).to.equal(frozen); //0.2
            expect(await project1.getBalance()).to.equal(frozen);
            expect(await ethers.provider.getBalance(project1Address)).to.equal(frozen); //0.2
            
            // platformOwner receives txn fee
            currOwnerBalance = await ethers.provider.getBalance(appOwner.address);
            expect(currOwnerBalance - prevOwnerBalance).to.equal(transactionFee);

            // founder received their share (minus gas costs)
            currFounderBalance = await ethers.provider.getBalance(founder1.address);
            expect(currFounderBalance - prevFounderBalance + gasUsed).to.equal(founderShare);
        });
    });

    describe("Platform owner transfer", function () {
        it("Should allow platform owner to transfer ownership", async function () {
            await expect(app.connect(appOwner).setPlatformOwner(backer1.address))
                .to.emit(app, "CrowdfundingManagerUpdated")
                .withArgs(appOwner.address, backer1.address);

            expect(await app.platformOwner()).to.equal(backer1.address);
        });

        it("Should revert if non-platformowner tries to transfer ownership", async function () {
            await expect(
                app.connect(backer1).setPlatformOwner(backer2.address)
            ).to.be.revertedWith("Not the platform owner");
        });

        it("Should revert if transfer ownership to zero address", async function () {
            await expect(
                app.connect(appOwner).setPlatformOwner(ethers.ZeroAddress)
            ).to.be.revertedWith("Invalid address");
        });
    });
    describe("Can get all projects", function () {
        let project1, project2;
        let project1Address, project2Address;
        beforeEach(async function () {
            // each founder creates a project
            const {tx: tx1, projectAddress:_project1Address} = await createValidProject(founder1)
            const {tx: tx2, projectAddress:_project2Address} = await createValidProject(founder2)
            project1 = await ethers.getContractAt("CrowdfundingProject", _project1Address);
            project2 = await ethers.getContractAt("CrowdfundingProject", _project2Address);
            // add milestone
            await project1.connect(founder1).addMilestone("Milestone 1", descCID, halfEther, milestoneDeadline);
            await project2.connect(founder2).addMilestone("Milestone 1", descCID, halfEther, milestoneDeadline);
            project1Address = _project1Address;
            project2Address = _project2Address;
            // start funding
            await project1.connect(founder1).startFunding();
            await project2.connect(founder2).startFunding();
        });
        it("Can Get all funding Projects", async function () {
            const projects = await app.getAllFundingProjects();
            expect(projects.length).to.equal(2);
            expect(projects[0]).to.equal(project1Address);
            expect(projects[1]).to.equal(project2Address);
        });
        it("Can Get all Working Projects", async function () {


        });
    });

});