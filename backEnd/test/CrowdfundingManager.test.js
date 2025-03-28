const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CrowdfundingManager", function () {
    let app, ProjectToken;
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
    const descCID =    'Description. Should be 32b Hash.';
    const photoCID =   'photoCID____ Should be 32b Hash.';
    // const XdotComCID = 'XdotComCID__ Should be 32b Hash.';
    const socialMediaLinkCID = 'SocialMedia. Should be 32b Hash.';
    const tokenSupply = ethers.parseEther("1000");
    const salt = ethers.id("salt123");
    const tokenName = "BCR";
    const tokenSymbol = 'XdotComCID__ Should be 32b Hash.';
    let projectContract;
    let fundingDeadline;
    let milestoneDeadline;
    const oneDay = 86400;

    function createValidProject(founder) {
        return app.connect(founder).createProject(
            projectName, fundingDeadline,
            tokenName, tokenSymbol, tokenSupply,
            salt, descCID, photoCID, socialMediaLinkCID
        );
    }


    beforeEach(async function () {
        [appOwner, founder1, founder2, backer1, backer2] = await ethers.getSigners();

        // Current time + 1 day in seconds
        
        fundingDeadline = Math.floor(Date.now() / 1000) + oneDay;
        milestoneDeadline = fundingDeadline + oneDay;

        // cfdTokenAddress = "0x1234";
        // crowdfundingPlatform = await ethers.deployContract("CrowdfundingPlatform", [cfdTokenAddress]);
        let appFactory = await ethers.getContractFactory("CrowdfundingManager", appOwner);
        app = await appFactory.deploy();
        // app = await appFactory.deploy("Temp", "TMP", tokenSupply, salt);

         // Deploy ProjectToken logic contract
        ProjectTokenFactory = await ethers.getContractFactory("ProjectToken");
        ProjectToken = await ProjectTokenFactory.deploy("Temp", "TMP", 1, appOwner.address); 

    });

    describe("Deployment", function () {
        it("Should set the correct platform plaftformOwner", async function () {
            expect(await app.platformOwner()).to.equal(appOwner.address);
        });

        it("Should set the correct platform fee", async function () {
            expect(await app.PLATFORM_FEE_PERCENT()).to.equal(1);
        });
    });

    describe("Project creation", function () {
        it("Should create a project with correct parameters", async function () {
            // No project yet
            expect(await app.projectCount()).to.equal(0);

            // create a project
            expect(await createValidProject(founder1))
                .to.emit(app, "ProjectCreated")
                .withArgs(1, founder1.address, fundingDeadline, descCID, photoCID, socialMediaLinkCID);

            // check project count increased
            expect(await app.projectCount()).to.equal(1);

            // Get project details
            const projectAddress = await app.projects(1);
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
                tokenName, tokenSymbol, tokenSupply,
                salt, descCID, photoCID, socialMediaLinkCID
            )).to.be.revertedWith("Deadline must be in the future");
        });
        it("Should revert if project name is empty or exceeds 100 characters", async function () {
            await expect(
                app.connect(founder1).createProject(
                    "", fundingDeadline,
                    tokenName, tokenSymbol, tokenSupply,
                    salt, descCID, photoCID, socialMediaLinkCID)
            ).to.be.revertedWith("Project name length must be between 1 and 100 characters");

            await expect(
                app.connect(founder1).createProject(
                    "a".repeat(200), fundingDeadline,
                    tokenName, tokenSymbol, tokenSupply,
                    salt, descCID, photoCID, socialMediaLinkCID)
            ).to.be.revertedWith("Project name length must be between 1 and 100 characters");
            // valid project names
            app.connect(founder1).createProject(
                "a".repeat(1), fundingDeadline,
                tokenName, tokenSymbol, tokenSupply,
                salt, descCID, photoCID, socialMediaLinkCID
            );
            app.connect(founder1).createProject(
                "a".repeat(100), fundingDeadline,
                tokenName, tokenSymbol, tokenSupply,
                salt, descCID, photoCID, socialMediaLinkCID
            )
        });
        it("Should revert if any IPFS has a wrong format", async function () {
            // TODO: checks only the length now, should check the format
            for(const x of [0,200]){
                await expect(
                    app.connect(founder1).createProject(
                        projectName, fundingDeadline,
                        tokenName, tokenSymbol, tokenSupply,
                        salt, "a".repeat(x), photoCID, socialMediaLinkCID)
                ).to.be.revertedWith("Invalid IPFS hash");
                await expect(
                    app.connect(founder1).createProject(
                        projectName, fundingDeadline,
                        tokenName, tokenSymbol, tokenSupply,
                        salt, descCID, "a".repeat(x), socialMediaLinkCID)
                ).to.be.revertedWith("Invalid IPFS hash");
                await expect(
                    app.connect(founder1).createProject(
                        projectName, fundingDeadline,
                        tokenName, tokenSymbol, tokenSupply,
                        salt, descCID, photoCID, "a".repeat(x))
                ).to.be.revertedWith("Invalid IPFS hash");
            }
        });
      
        it("Should record multiple projects for a founder in the founders mapping", async function () {
          // founder1 creates two projects
            await expect(
                await createValidProject(founder1)
            ).to.emit(app, "ProjectCreated").withArgs(
                1, founder1.address, fundingDeadline, 
                tokenName, tokenSymbol, tokenSupply,
                descCID, photoCID, socialMediaLinkCID
            );

            await expect(
                await createValidProject(founder1)
            ).to.emit(app, "ProjectCreated").withArgs(
                2, founder1.address, fundingDeadline, 
                tokenName, tokenSymbol, tokenSupply,
                descCID, photoCID, socialMediaLinkCID
            );

            // check projects mapping has two projects
            expect(await app.projectCount()).to.equal(2);

            // check founders mapping 
            const projectIds = await app.getFounderProjects(founder1.address);
            expect(projectIds.length).to.equal(2);
            expect(projectIds[0]).to.equal(1);
            expect(projectIds[1]).to.equal(2);
      });
    });
    describe("Adding Milestones", function () {
        let project1Address, project1;
        let project2Address, project2;
        beforeEach(async function () {
            // each founder creates a project
            await createValidProject(founder1);
            await createValidProject(founder2);
            project1Address = await app.projects(1);
            project2Address = await app.projects(2);
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
        let project1Address, project1;
        beforeEach(async function () {
            // each founder creates a project
            await createValidProject(founder1);
            project1Address = await app.projects(1);
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
        let project1Address, project1;
        beforeEach(async function () {
            // each founder creates a project
            await createValidProject(founder1);
            project1Address = await app.projects(1);
            project1 = await ethers.getContractAt("CrowdfundingProject", project1Address);
            await project1.connect(founder1).addMilestone("Milestone 1",descCID,oneEther,milestoneDeadline)
            await project1.connect(founder1).startFunding();
        });

        it("Should allow invest to an funding project", async function () {
            await expect(project1.connect(backer1).invest({ value: oneEther }))
                .to.emit(project1, "InvestmentMade")
                .withArgs(backer1.address, oneEther);

            // check project funded amount
            expect(await project1.fundingBalance()).to.equal(oneEther);
        });

        it("Should allow multiple investments from the same backer", async function () {
            await project1.connect(backer1).invest({ value: halfEther });
            await project1.connect(backer1).invest({ value: halfEther });

            // check project funded amount
            expect(await project1.fundingBalance()).to.equal(ethers.parseEther("1"));
        });

        it("Should revert if project is not funding", async function () {
            // create and add milestone but not start funding
            await createValidProject(founder2);
            let project2 = await ethers.getContractAt("CrowdfundingProject", await app.projects(2));
            await expect(
                project2.connect(backer1).invest({ value: oneEther })
            ).to.be.revertedWith("Project is not funding");
        });
        it("Should not allow investment after funding deadline", async function () {
            // Create a project with a short funding deadline
            let block = await ethers.provider.getBlock("latest");
            const shortDeadline = block.timestamp + 10; // 10 seconds from now
            await app.connect(founder2).createProject(
            projectName, shortDeadline,
            tokenName, tokenSymbol, tokenSupply,
            salt, descCID, photoCID, socialMediaLinkCID
            );
            let project2 = await ethers.getContractAt("CrowdfundingProject", await app.projects(2));
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


    describe("Fund withdrawal", function () {
        beforeEach(async function () {
            // create a project
            await app.connect(founder1).createProject(projectName, fundingDeadline, descCID, photoCID, socialMediaLinkCID);

            // add milestone
            await app.connect(founder1).addMilestone(1, "Milestone 1", descCID, oneEther, milestoneDeadline);
            await app.connect(founder1).startFunding();
        });

        it("Should allow founder to withdraw funds after approval", async function () {
            await expect(app.connect(backer1).invest({ value: oneEther }))
                .to.emit(app, "InvestmentMade")
                .withArgs(1, backer1.address, oneEther);
            

            const initialFounderBalance = await ethers.provider.getBalance(founder1.address);
            const initialOwnerBalance = await ethers.provider.getBalance(appOwner.address);

            // txn fee and founder share
            const projectGoalBigInt = projectGoal;
            const transactionFee = projectGoalBigInt * BigInt(1) / BigInt(100); // 1% fee
            const founderShare = projectGoalBigInt - transactionFee;

            // // founder withdraws funds
            // const withdrawTx = await crowdfundingPlatform.connect(founder1).withdraw(1);
            // const receipt = await withdrawTx.wait();
            // const gasUsed = receipt.gasUsed * receipt.gasPrice;

            // // check project status changed to Finished
            // const project = await crowdfundingPlatform.projects(1);
            // expect(project.status).to.equal(3); // ProjectStatus.Finished
            // expect(project.fundingBalance).to.equal(0); // Funds should be reset to 0

            // // plaftformOwner receives txn fee
            // const finalOwnerBalance = await ethers.provider.getBalance(plaftformOwner.address);
            // expect(finalOwnerBalance - initialOwnerBalance).to.equal(transactionFee);

            // // founder received their share (minus gas costs)
            // const finalFounderBalance = await ethers.provider.getBalance(founder1.address);
            // expect(finalFounderBalance - initialFounderBalance + gasUsed).to.equal(founderShare);
        });

        
    });



    describe("Plaftform owner transfer", function () {
        it("Should allow platform owner to transfer ownership", async function () {
            await expect(app.connect(appOwner).updatePlatformOwner(backer1.address))
                .to.emit(app, "PlatformOwnerUpdated")
                .withArgs(appOwner.address, backer1.address);

            expect(await app.platformOwner()).to.equal(backer1.address);
        });

        it("Should revert if non-plaftformowner tries to transfer ownership", async function () {
            await expect(
                app.connect(backer1).updatePlatformOwner(backer2.address)
            ).to.be.revertedWith("Not the platform owner");
        });

        it("Should revert if transfer ownership to zero address", async function () {
            await expect(
                app.connect(appOwner).updatePlatformOwner(ethers.ZeroAddress)
            ).to.be.revertedWith("Invalid address");
        });
    });

    describe("Project token", function() {
        it("should compute the expected token address", async () => {
            const computedAddr = await projectContract.computeTokenAddress();
            console.log("Predicted token address:", computedAddr);
            expect(computedAddr).to.properAddress;
          });
        
          it("should deploy the token when funding is successful", async () => {
            // Simulate investments (you may need to adjust this based on your function signatures)
            await projectContract.connect(investor1).invest({ value: ethers.utils.parseEther("6") });
            await projectContract.connect(investor2).invest({ value: ethers.utils.parseEther("4") });
        
            // Trigger token deployment
            await projectContract.deployTokenIfSuccessful(projectId);
            const tokenAddr = await projectContract.projectToken();
            expect(tokenAddr).to.properAddress;
          });
        
          it("should distribute tokens to investors proportionally", async () => {
            await projectContract.connect(investor1).invest({ value: ethers.utils.parseEther("6") });
            await projectContract.connect(investor2).invest({ value: ethers.utils.parseEther("4") });
        
            await projectContract.deployTokenIfSuccessful(projectId);
            const tokenAddr = await projectContract.projectToken();
            const tokenInstance = await ethers.getContractAt("ProjectToken", tokenAddr);
        
            await projectContract.distributeTokens(projectId);
        
            const balance1 = await tokenInstance.balanceOf(investor1.address);
            const balance2 = await tokenInstance.balanceOf(investor2.address);
        
            expect(balance1).to.equal(ethers.utils.parseEther("600")); // 60% of total supply
            expect(balance2).to.equal(ethers.utils.parseEther("400")); // 40% of total supply
          });
    });

});