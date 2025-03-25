const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CrowdfundingPlatform", function () {
    let crowdfundingPlatform;
    let plaftformOwner;
    let founder1;
    let founder2;
    let backer1;
    let backer2;

    // for CFDToken test, CFDToken.sol?
    //   let cfdTokenAddress;       

    // Project parameters
    const projectName = "BlockCrafters";
    const projectGoal = ethers.parseEther("10");
    const oneEther = ethers.parseEther("1");
    const halfEther = ethers.parseEther("0.5");
    const descIPFSHash = 'Description. Should be 32b Hash.';
    let fundingDeadline;
    let milestoneDeadline;
    beforeEach(async function () {
        [plaftformOwner, founder1, founder2, backer1, backer2] = await ethers.getSigners();

        // Current time + 1 day in seconds
        fundingDeadline = Math.floor(Date.now() / 1000) + 86400;
        milestoneDeadline = fundingDeadline + 86400;

        // cfdTokenAddress = "0x1234";

        // crowdfundingPlatform = await ethers.deployContract("CrowdfundingPlatform", [cfdTokenAddress]);
        crowdfundingPlatform = await ethers.deployContract("CrowdfundingPlatform");

    });

    describe("Deployment", function () {
        it("Should set the correct platform plaftformOwner", async function () {
            expect(await crowdfundingPlatform.platformOwner()).to.equal(plaftformOwner.address);
        });

        it("Should set the correct platform fee", async function () {
            expect(await crowdfundingPlatform.PLATFORM_FEE_PERCENT()).to.equal(1);
        });
    });

    describe("Project creation", function () {
        it("Should create a project with correct parameters", async function () {
            // No project yet
            expect(await crowdfundingPlatform.projectCount()).to.equal(0);

            // create a project
            await expect(crowdfundingPlatform.connect(founder1).createProject(
                projectName,
                fundingDeadline,
                descIPFSHash
            ))
                .to.emit(crowdfundingPlatform, "ProjectCreated")
                .withArgs(1, founder1.address, fundingDeadline, descIPFSHash);

            // check project count increased
            expect(await crowdfundingPlatform.projectCount()).to.equal(1);

            // Get project details
            const project = await crowdfundingPlatform.projects(1);

            // Verify project details
            expect(project.founder).to.equal(founder1.address);
            expect(await crowdfundingPlatform.getProjectFundingGoal(1)).to.equal(0);
            expect(project.fundingBalance).to.equal(0);
            expect(project.status).to.equal(0); // ProjectStatus.Active = 0
            expect(project.fundingDeadline).to.equal(fundingDeadline);
            expect(project.descIPFSHash).to.equal(descIPFSHash);
        });

        it("Should revert if deadline is in the past", async function () {
            const pastDeadline = Math.floor(Date.now() / 10000) - 10000; // Past timestamp

            await expect(
                crowdfundingPlatform.connect(founder1).createProject(
                    projectName,
                    pastDeadline,
                    descIPFSHash
                )).to.be.revertedWith("Deadline must be in the future");
        });
        it("Should revert if project name is empty or exceeds 100 characters", async function () {
            await expect(
                crowdfundingPlatform.connect(founder1).createProject("", fundingDeadline, descIPFSHash)
            ).to.be.revertedWith("Project name length must be between 1 and 100 characters");

            await expect(
                crowdfundingPlatform.connect(founder1).createProject("a".repeat(200), fundingDeadline, descIPFSHash)
            ).to.be.revertedWith("Project name length must be between 1 and 100 characters");
            // valid project names
            crowdfundingPlatform.connect(founder1).createProject("a".repeat(1), fundingDeadline, descIPFSHash)
            crowdfundingPlatform.connect(founder1).createProject("a".repeat(100), fundingDeadline, descIPFSHash)
        });
        it("Should revert if project description IPFSHASH has a wrong format", async function () {
            // TODO: checks only the length now, should check the format
            await expect(
                crowdfundingPlatform.connect(founder1).createProject(projectName, fundingDeadline, "a".repeat(200))
            ).to.be.revertedWith("Invalid IPFS hash");
        });
    });
    describe("Adding Milestones", function () {
        beforeEach(async function () {
            // each founder creates a project
            await crowdfundingPlatform.connect(founder1).createProject(projectName, fundingDeadline, descIPFSHash);
            await crowdfundingPlatform.connect(founder2).createProject(projectName, fundingDeadline, descIPFSHash);
        });
        it("Should add a milestone with correct parameters", async function () {
            await expect(crowdfundingPlatform.connect(founder1).addMilestone(
                1, // projectID
                "Milestone 1", // name (string)
                descIPFSHash, // description (string)
                oneEther, // fundingGoal (uint256)
                milestoneDeadline // deadline (uint256)
            ))
                .to.emit(crowdfundingPlatform, "MilestoneAdded")
                .withArgs(1, 1, "Milestone 1", descIPFSHash, oneEther, milestoneDeadline);

        });
        it("Project should be updated with the correct funding goal", async function () {
            await crowdfundingPlatform.connect(founder1).addMilestone(1, "Milestone 1", descIPFSHash, oneEther, milestoneDeadline);
            expect(await crowdfundingPlatform.getProjectFundingGoal(1)).to.equal(oneEther);
        });
        it("Should revert if the project doesn't exist", async function () {
            await expect(
                crowdfundingPlatform.connect(founder1).addMilestone(10, "Milestone 1", descIPFSHash, oneEther, milestoneDeadline)
            ).to.be.revertedWith("Project does not exist");
        });
        it("Should revert if the project doesn't belong to the msg.sender", async function () {
            await expect(
                crowdfundingPlatform.connect(founder2).addMilestone(1, "Milestone 1", descIPFSHash, oneEther, milestoneDeadline)
            ).to.be.revertedWith("Only the founder can perform this action");
        });
        it("Should revert if milestone Goal is not a positive number", async function () {
            await expect(
                crowdfundingPlatform.connect(founder1).addMilestone(1, "Milestone 1", descIPFSHash, ethers.parseEther("0"), milestoneDeadline)
            ).to.be.revertedWith("Milestone goal must be positive");
        });
        it("Should revert if deadline is in the past", async function () {
            const pastDeadline = Math.floor(Date.now() / 10000) - 10000; // Past timestamp
            await expect(
                crowdfundingPlatform.connect(founder1).addMilestone(1, "Milestone 1", descIPFSHash, oneEther, pastDeadline)
            ).to.be.revertedWith("Deadline must be in the future");
        });
        it("Should revert if milestone deadline is before previous milestone", async function () {
            await crowdfundingPlatform.connect(founder1).addMilestone(1, "Milestone 1", descIPFSHash, oneEther, milestoneDeadline);
            await expect(
                crowdfundingPlatform.connect(founder1).addMilestone(1, "Milestone 2", descIPFSHash, oneEther, milestoneDeadline - 1000)
            ).to.be.revertedWith("Milestone deadline must be after the previous milestone");
        });
    });
    describe("Start Project Funding", function () {
        beforeEach(async function () {
            // create a project
            await crowdfundingPlatform.connect(founder1).createProject(projectName, fundingDeadline, descIPFSHash);
            await crowdfundingPlatform.connect(founder1).addMilestone(1, "Milestone 1", descIPFSHash, oneEther, milestoneDeadline);
        });
        it("Founder can start funding for a project", async function () {
            expect(await crowdfundingPlatform.connect(founder1).startFunding(1))
                .to.emit(crowdfundingPlatform, "ProjectStatusUpdated")
                .withArgs(1, 1, 0);
        });
        it("Should revert if the project doesn't exist", async function () {
            await expect(
                crowdfundingPlatform.connect(founder1).startFunding(10)
            ).to.be.revertedWith("Project does not exist");
        });
        it("Should revert if the project is already active", async function () {
            await crowdfundingPlatform.connect(founder1).startFunding(1);
            await expect(
                crowdfundingPlatform.connect(founder1).startFunding(1)
            ).to.be.revertedWith("Can only start funding if project is inactive");
        });
        it("Should revert if the project is already funding", async function () {
            await crowdfundingPlatform.connect(founder1).startFunding(1);
            await expect(
                crowdfundingPlatform.connect(founder1).startFunding(1)
            ).to.be.revertedWith("Can only start funding if project is inactive");
        });
        it("Should revert if the project doesn't belong to the msg.sender", async function () {
            await expect(
                crowdfundingPlatform.connect(founder2).startFunding(1)
            ).to.be.revertedWith("Only the founder can perform this action");
        });
    });

    describe("Project investment", function () {
        beforeEach(async function () {
            // create a project
            await crowdfundingPlatform.connect(founder1).createProject(projectName, fundingDeadline, descIPFSHash);
            await crowdfundingPlatform.connect(founder1).addMilestone(1, "Milestone 1", descIPFSHash, oneEther, milestoneDeadline);
            await crowdfundingPlatform.connect(founder1).startFunding(1);
        });

        it("Should allow invest to an funding project", async function () {
            await expect(crowdfundingPlatform.connect(backer1).invest(1, oneEther, { value: oneEther }))
                .to.emit(crowdfundingPlatform, "InvestmentMade")
                .withArgs(1, backer1.address, oneEther);

            // check project funded amount
            const project = await crowdfundingPlatform.projects(1);
            expect(project.fundingBalance).to.equal(oneEther);
        });

        it("Should allow multiple investments from the same backer", async function () {
            await crowdfundingPlatform.connect(backer1).invest(1, halfEther, { value: halfEther });
            await crowdfundingPlatform.connect(backer1).invest(1, halfEther, { value: halfEther });

            // check project funded amount
            const project = await crowdfundingPlatform.projects(1);
            expect(project.fundingBalance).to.equal(ethers.parseEther("1"));
        });

        it("Should revert if specified investing amount doesn't match sent value", async function () {
            await expect(
                crowdfundingPlatform.connect(backer1).invest(1, oneEther, { value: halfEther })
            ).to.be.revertedWith("Send exact amount");
        });
        it("Should revert if project is not funding", async function () {
            // Set the project to approved = 1 (active = 0)
            await crowdfundingPlatform.connect(founder2).createProject(projectName, fundingDeadline, descIPFSHash);
            await crowdfundingPlatform.connect(founder2).addMilestone(2, "Milestone 1", descIPFSHash, oneEther, milestoneDeadline);

            await expect(
                crowdfundingPlatform.connect(backer1).invest(2, oneEther, { value: oneEther })
            ).to.be.revertedWith("Project is not funding");
        });
        it("Should not allow investment after funding deadline", async function () {
            //TODO: mark project as failed if deadline passed and someone checks the status
            let time = Date.now();
            await crowdfundingPlatform.connect(founder2).createProject(projectName, time + 1, descIPFSHash);
            await crowdfundingPlatform.connect(founder2).addMilestone(2, "Milestone 1", descIPFSHash, oneEther, time + 10);
            await crowdfundingPlatform.connect(founder2).startFunding(2);
            while (Date.now() < time + 100) { }
            await expect(
                crowdfundingPlatform.connect(backer1).invest(2, oneEther, { value: oneEther })
            ).to.be.revertedWith("Funding deadline has passed");
        });
        it("Should end funding and activate project if goal is reached", async function () {
            await crowdfundingPlatform.connect(backer1).invest(1, oneEther, { value: oneEther });
            // check project status changed to Approved
            const project = await crowdfundingPlatform.projects(1);
            expect(project.status).to.equal(2); // ProjectStatus.Active
        });
        it("Should revert if investment is larger than the remaining funding goal", async function () {
            await expect(
                crowdfundingPlatform.connect(backer1).invest(1, projectGoal + oneEther, { value: projectGoal + oneEther })
            ).to.be.revertedWith("Investment exceeds funding goal");
        });
        it("Should revert if project goal is already reached", async function () {
            await crowdfundingPlatform.connect(backer1).invest(1, oneEther, { value: oneEther });
            await expect(
                crowdfundingPlatform.connect(backer1).invest(1, oneEther, { value: oneEther })
            ).to.be.revertedWith("Project is not funding");
        });
    });

    // describe("Project status updates", function () {
    //   beforeEach(async function () {
    //     // create a project
    //     await crowdfundingPlatform.connect(founder1).createProject(projectName,fundingDeadline,descIPFSHash);
    //   });

    //   it("Should change project status to Approved", async function () {
    //     await expect(crowdfundingPlatform.setProjectApproved(1))
    //       .to.emit(crowdfundingPlatform, "ProjectStatusUpdated")
    //       .withArgs(1, 1); // 1 = ProjectStatus.Approved

    //     const project = await crowdfundingPlatform.projects(1);
    //     expect(project.status).to.equal(1); // ProjectStatus.Approved
    //   });

    //   it("Should change project status to Failed", async function () {
    //     await expect(crowdfundingPlatform.setProjectFailed(1))
    //       .to.emit(crowdfundingPlatform, "ProjectStatusUpdated")
    //       .withArgs(1, 2); // 2 is ProjectStatus.Failed

    //     const project = await crowdfundingPlatform.projects(1);
    //     expect(project.status).to.equal(2); // ProjectStatus.Failed
    //   });

    //   it("Should revert if project is not active when updating status", async function () {
    //     // first set the project to approved
    //     await crowdfundingPlatform.setProjectApproved(1);

    //     // then set to failed
    //     await expect(
    //       crowdfundingPlatform.setProjectFailed(1)
    //     ).to.be.revertedWith("Project not active");
    //   });
    // });

    describe("Fund withdrawal", function () {
        beforeEach(async function () {
            // create a project
            await crowdfundingPlatform.connect(founder1).createProject(projectName, fundingDeadline, descIPFSHash);

            // Fully fud the project to goal (1=1)
            await crowdfundingPlatform.connect(backer1).invest(1, projectGoal, { value: projectGoal });

            // Approve the project
            await crowdfundingPlatform.setProjectApproved(1);
        });

        it("Should allow founder to withdraw funds after approval", async function () {
            const initialFounderBalance = await ethers.provider.getBalance(founder1.address);
            const initialOwnerBalance = await ethers.provider.getBalance(plaftformOwner.address);

            // txn fee and founder share
            const projectGoalBigInt = projectGoal;
            const transactionFee = projectGoalBigInt * BigInt(1) / BigInt(100); // 1% fee
            const founderShare = projectGoalBigInt - transactionFee;

            // founder withdraws funds
            const withdrawTx = await crowdfundingPlatform.connect(founder1).withdraw(1);
            const receipt = await withdrawTx.wait();
            const gasUsed = receipt.gasUsed * receipt.gasPrice;

            // check project status changed to Finished
            const project = await crowdfundingPlatform.projects(1);
            expect(project.status).to.equal(3); // ProjectStatus.Finished
            expect(project.fundingBalance).to.equal(0); // Funds should be reset to 0

            // plaftformOwner receives txn fee
            const finalOwnerBalance = await ethers.provider.getBalance(plaftformOwner.address);
            expect(finalOwnerBalance - initialOwnerBalance).to.equal(transactionFee);

            // founder received their share (minus gas costs)
            const finalFounderBalance = await ethers.provider.getBalance(founder1.address);
            expect(finalFounderBalance - initialFounderBalance + gasUsed).to.equal(founderShare);
        });

        it("Should revert if non-founder tries to withdraw", async function () {
            await expect(
                crowdfundingPlatform.connect(backer1).withdraw(1)
            ).to.be.revertedWith("Only founder can withdraw");
        });

        it("Should revert if goal not reached", async function () {
            // new proj w/ a higher goal
            await crowdfundingPlatform.connect(founder1).createProject(
                ethers.parseEther("20"),
                fundingDeadline
            );

            // Fund it partially
            await crowdfundingPlatform.connect(backer1).invest(2, oneEther, { value: oneEther });

            // Approve it
            await crowdfundingPlatform.setProjectApproved(2);

            //withdraw
            await expect(
                crowdfundingPlatform.connect(founder1).withdraw(2)
            ).to.be.revertedWith("Goal not reached");
        });

        it("Should revert if project not approved", async function () {
            // new project
            await crowdfundingPlatform.connect(founder1).createProject(
                oneEther,
                fundingDeadline
            );

            // fund it fully
            await crowdfundingPlatform.connect(backer1).invest(2, oneEther, { value: oneEther });

            // withdraw w/o approval
            await expect(
                crowdfundingPlatform.connect(founder1).withdraw(2)
            ).to.be.revertedWith("Project not approved");
        });
    });



    describe("Plaftform owner transfer", function () {
        it("Should allow platform owner to transfer ownership", async function () {
            await expect(crowdfundingPlatform.connect(plaftformOwner).updatePlatformOwner(backer1.address))
                .to.emit(crowdfundingPlatform, "PlatformOwnerUpdated")
                .withArgs(plaftformOwner.address, backer1.address);

            expect(await crowdfundingPlatform.platformOwner()).to.equal(backer1.address);
        });

        it("Should revert if non-plaftformowner tries to transfer ownership", async function () {
            await expect(
                crowdfundingPlatform.connect(backer1).updatePlatformOwner(backer2.address)
            ).to.be.revertedWith("Not the platform owner");
        });

        it("Should revert if transfer ownership to zero address", async function () {
            await expect(
                crowdfundingPlatform.connect(plaftformOwner).updatePlatformOwner(ethers.ZeroAddress)
            ).to.be.revertedWith("Invalid address");
        });
    });

});