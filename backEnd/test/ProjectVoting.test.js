const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("ProjectVoting", function () {
    let app;
    let appOwner;
    let founder1, founder2;
    let backer1, backer2;

    const projectName = "BlockCrafters";
    const projectGoal = ethers.parseEther("10");
    const oneEther = ethers.parseEther("1");
    const fiveEther = ethers.parseEther("5");
    const halfEther = ethers.parseEther("0.5");
    const descCID =    'Description. Should be 46b Hash.'+'-'.repeat(14);
    const photoCID =   'photoCID Should be 46b Hash.'+'-'.repeat(18);
    // const XdotComCID = 'XdotComCID__ Should be 46b Hash.';
    const socialMediaLinkCID = 'SocialMedia. Should be 46b Hash.'+'-'.repeat(14);
    const tokenSupply = ethers.parseEther("1000");
    const salt = ethers.id("salt123");
    const tokenName = "BCR";
    const tokenSymbol = 'XdotComCID Should be 46b Hash.'+'-'.repeat(16);
    let projectContract;
    let fundingDeadline;
    let milestoneDeadline;
    const oneDay = 86400;
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

        // cfdTokenAddress = "0x1234";
        // crowdfundingPlatform = await ethers.deployContract("CrowdfundingPlatform", [cfdTokenAddress]);
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
    });    
    describe("Milestone Extension", function () {
        let  project1, project1Address;
        let votingPlatform;
        beforeEach(async function () {
            const {tx: tx1, projectAddress:_project1Address} = await createValidProject(founder1)
            project1 = await ethers.getContractAt("CrowdfundingProject", _project1Address);
            await project1.connect(founder1).addMilestone("Milestone 1", descCID, fiveEther, milestoneDeadline);
            await project1.connect(founder1).startFunding();
            votingPlatform = await ethers.getContractAt("ProjectVoting", await project1.votingPlatform());
            project1Address = _project1Address;
        });
        it("Can Start an Extension request", async function () {
            // activate the project
            await project1.connect(backer1).invest({value:  fiveEther});
            // request extension
            await project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay);
            const voting = await votingPlatform.getVoting(0,-1);
            expect(voting.voteType).to.equal(0); //Extension
        });
        it("can view the ongoing voting with viewCurrentVoting()", async function () {
            // activate the project
            await project1.connect(backer1).invest({value:  fiveEther});
            // request extension
            await project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay);
            const res = await votingPlatform.viewCurrentVoting();
            expect(res.map(n => Number(n))).to.deep.equal([0, 0, 0, 0]); // milestoneID, votingID, VoteType.Extension, VoteStatus.Pending
        });
        it("Backers can vote for/against extension", async function () {
            // activate the project
            // console.log(project.fundingBalance);
            await project1.connect(backer1).invest({value: ethers.parseEther('2')});
            await project1.connect(backer2).invest({value: ethers.parseEther('3')});
            await project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay);
            // vote
            await votingPlatform.connect(backer1).vote(0, true);
            let voting = await votingPlatform.getVoting(0,-1);
            expect(voting.result).to.equal(0); //pending
            await votingPlatform.connect(backer2).vote(0, false);
            voting = await votingPlatform.getVoting(0,-1);
            expect(voting.positives).to.equal( ethers.parseEther('2'));
            expect(voting.negatives).to.equal( ethers.parseEther('3'));
        });
        it("Can't vote if no voting requested", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: oneEther});
            // vote
            await expect(
                votingPlatform.connect(backer1).vote(0, true)
            ).to.be.revertedWith("No voting has started yet");
        });
        it("Can't vote twice", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: fiveEther});
            // request extension
            await project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay);
            // vote
            await votingPlatform.connect(backer1).vote(0, true);
            await expect(
                votingPlatform.connect(backer1).vote(0, false)
            ).to.be.revertedWith("Already voted");
        });

        it("NonBackers can't vote", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: fiveEther});
            // request extension
            await project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay);
            // vote
            await expect(
                votingPlatform.connect(backer2).vote(0, true)
            ).to.be.revertedWith("You have no voting power");
        });  
        it("Deadline should remain before approval", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: fiveEther});
            // request extension
            await project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay);
            // const project = await app.projects(1);
            const milestone = await project1.getMilestone(0);
            expect(milestone.deadline).to.equal(milestoneDeadline);
        });
        it("Extension Approved if votepower>50%, and deadline is extended", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: ethers.parseEther('2')});
            await project1.connect(backer2).invest({value: ethers.parseEther('3')});
            // request extension
            await project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay);
            // vote
            await votingPlatform.connect(backer1).vote(0, false);
            await votingPlatform.connect(backer2).vote(0, true);
            const voting = await votingPlatform.getVoting(0,-1);
            expect(voting.result).to.equal(1); //Approved
            const milestone = await project1.getMilestone(0);
            expect(milestone.deadline).to.equal(milestoneDeadline+oneDay);
        });
        it("Extension Rejected if negative votepower>=50%, and deadline is not extended", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: ethers.parseEther('2.5')});
            await project1.connect(backer2).invest({value: ethers.parseEther('2.5')});
            // request extension
            await project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay);
            // vote
            await votingPlatform.connect(backer1).vote(0, false);
            await votingPlatform.connect(backer2).vote(0, true);
            let voting = await votingPlatform.getVoting(0,-1);
            expect(voting.result).to.equal(2); //rejected
            let milestone = await project1.getMilestone(0);
            expect(milestone.deadline).to.equal(milestoneDeadline);
        });
        it("Can't Start an Extension request if not founder", async function () {
            await project1.connect(backer1).invest({value: ethers.parseEther('5')});
            await expect(
                project1.connect(founder2).requestExtension(0, milestoneDeadline + oneDay)
            ).to.be.revertedWith("Only the founder can perform this action");
        });
        it("Can't Start an Extension request if project not active", async function () {
            await expect(
                project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay)
            ).to.be.revertedWith("Project is not active");
        });

    });
    describe("Milestone Advance", function () {
        //TODO: add tests for milestone advance
        let  project1;
        let votingPlatform;
        beforeEach(async function () {
            const {tx: tx1, projectAddress:project1Address} = await createValidProject(founder1)
            project1 = await ethers.getContractAt("CrowdfundingProject", project1Address);
            await project1.connect(founder1).addMilestone("Milestone 1", descCID, ethers.parseEther("2"), milestoneDeadline);
            await project1.connect(founder1).addMilestone("Milestone 2", descCID, ethers.parseEther("3"), milestoneDeadline+1000);
            await project1.connect(founder1).startFunding();
            votingPlatform = await ethers.getContractAt("ProjectVoting", await project1.votingPlatform());
        });
        
        it("Can Start an Advance request", async function () {
            // activate the project
            await project1.connect(backer1).invest({value:  fiveEther});
            // request advance
            await project1.connect(founder1).requestAdvance();
            const voting = await votingPlatform.getVoting(0,-1);
            expect(voting.voteType).to.equal(1); //Advance
        });
        it("Should fail an Advance request if project is not active", async function () {
            await expect(
                project1.connect(founder1).requestAdvance()
            ).to.be.revertedWith("Project is not active");
        });
        it("Can view the ongoing voting with viewCurrentVoting()", async function () {
            // activate the project
            await project1.connect(backer1).invest({value:  fiveEther});
            // request extension
            await project1.connect(founder1).requestAdvance();
            const res = await votingPlatform.viewCurrentVoting();
            expect(res.map(n => Number(n))).to.deep.equal([0, 0, 1, 0]);  // milestoneID, VotingID, VoteType.Advance, VotingResult.Pending, 
        });
        it("Backers can vote for/against advance", async function () {
            // activate the project
            // console.log(project.fundingBalance);
            await project1.connect(backer1).invest({value: ethers.parseEther('2')});
            await project1.connect(backer2).invest({value: ethers.parseEther('3')});
            await project1.connect(founder1).requestAdvance();
            // vote
            await votingPlatform.connect(backer1).vote(0, true);
            let voting = await votingPlatform.getVoting(0,-1);
            expect(voting.result).to.equal(0); //pending
            await votingPlatform.connect(backer2).vote(0, false);
            voting = await votingPlatform.getVoting(0,-1);
            expect(voting.positives).to.equal( ethers.parseEther('2'));
            expect(voting.negatives).to.equal( ethers.parseEther('3'));
        });
        it("Can't vote if no voting requested", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: oneEther});
            // vote
            await expect(
                votingPlatform.connect(backer1).vote(0, true)
            ).to.be.revertedWith("No voting has started yet");
        });
        it("Can't vote twice", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: fiveEther});
            // request extension
            await project1.connect(founder1).requestAdvance();
            // vote
            await votingPlatform.connect(backer1).vote(0, true);
            await expect(
                votingPlatform.connect(backer1).vote(0, false)
            ).to.be.revertedWith("Already voted");
        });

        it("NonBackers can't vote", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: fiveEther});
            // request extension
            await project1.connect(founder1).requestAdvance();
            // vote
            await expect(
                votingPlatform.connect(backer2).vote(0, true)
            ).to.be.revertedWith("You have no voting power");
        });  
        it("CurrentMilestone should remain before approval", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: fiveEther});
            // request extension
            await project1.connect(founder1).requestAdvance();
            // const project = await app.projects(1);
            const currentMilestone = await project1.getCurrentMilestone();
            expect(currentMilestone).to.equal(0);
        });
        it("Advance Approved if votepower>50%, and milestone advanced", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: ethers.parseEther('2')});
            await project1.connect(backer2).invest({value: ethers.parseEther('3')});
            // request extension
            await project1.connect(founder1).requestAdvance();
            // vote
            await votingPlatform.connect(backer1).vote(0, true);
            await votingPlatform.connect(backer2).vote(0, true);
            const voting = await votingPlatform.getVoting(0,-1);
            expect(voting.result).to.equal(1); //Approved
        });
        it("Project flagged as completed if all milestones are completed", async function () {
            expect(await project1.status()).to.equal(1); //Funding
            await project1.connect(backer1).invest({value: ethers.parseEther('2')});
            await project1.connect(backer2).invest({value: ethers.parseEther('3')});
            // request extension
            expect(await project1.status()).to.equal(2); //Active
            await project1.connect(founder1).requestAdvance();
            // vote
            await votingPlatform.connect(backer1).vote(0, true);
            await votingPlatform.connect(backer2).vote(0, true);
            await project1.connect(founder1).withdraw(); // withdraw milestone 0
            expect(await project1.getCurrentMilestone()).to.equal(1);
            // request extension
            await project1.connect(founder1).requestAdvance();
            // vote
            await votingPlatform.connect(backer1).vote(1, true);
            await votingPlatform.connect(backer2).vote(1, true);
            await project1.connect(founder1).withdraw(); // withdraw milestone 0
            expect(await project1.getCurrentMilestone()).to.equal(1);

            expect(await project1.status()).to.equal(4); //completed
        });
        it("Advance Rejected if votepower<=50%", async function () {
            // activate the project
            await project1.connect(backer1).invest({value: ethers.parseEther('2.5')});
            await project1.connect(backer2).invest({value: ethers.parseEther('2.5')});
            // request extension
            await project1.connect(founder1).requestAdvance();
            // vote
            await votingPlatform.connect(backer1).vote(0, false);
            await votingPlatform.connect(backer2).vote(0, true);
            let voting = await votingPlatform.getVoting(0,-1);
            expect(voting.result).to.equal(2); //rejected
            expect(await project1.getCurrentMilestone()).to.equal(0);
        });
        it("Can't Start an Advance request if not founder", async function () {
            await project1.connect(backer1).invest({value: ethers.parseEther('5')});
            await expect(
                project1.connect(founder2).requestAdvance()
            ).to.be.revertedWith("Only the founder can perform this action");
        });
        it("Can't Start an Advance request if project not active", async function () {
            await expect(
                project1.connect(founder1).requestAdvance()
            ).to.be.revertedWith("Project is not active");
        });
        
        
        
    });

});
