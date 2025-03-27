const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProjectVoting", function () {
    let app, votingPlatform, votingPlatformFactory;
    let platformOwner
    let founder1, founder2;
    let backer1, backer2;

    const projectName = "BlockCrafters";
    const projectGoal = ethers.parseEther("10");
    const oneEther = ethers.parseEther("1");
    const halfEther = ethers.parseEther("0.5");
    const fiveEther = ethers.parseEther("5");
    const descIPFSHash = 'Description. Should be 32b Hash.';  
    const tokenSupply = ethers.parseEther("1000");
    const salt = ethers.id("salt123");

    beforeEach(async function () {
        [plaftformOwner, founder1, founder2, backer1, backer2] = await ethers.getSigners();
        fundingDeadline = Math.floor(Date.now() / 1000) + 86400; 
        milestoneDeadline = fundingDeadline + 86400;
        const CrowdfundingPlatformFactory = await ethers.getContractFactory("CrowdfundingPlatform");
        app = await CrowdfundingPlatformFactory.deploy("Temp", "TMP", tokenSupply, salt);
        votingPlatform = await ethers.getContractAt("ProjectVoting", await app.votingPlatform());
        // console.log("CrowdfundingPlatform address:", app.address);
        // votingPlatform = await ethers.deployContract("ProjectVoting", [app.address]);
    });    
    describe("Milestone Extension", function () {
        beforeEach(async function () {
            // each founder creates a project
            await app.connect(founder1).createProject(projectName,fundingDeadline,descIPFSHash);
            // await votingPlatform.connect(founder1).createVoting(app.address, 1, "Milestone 1", descIPFSHash, milestoneDeadline);
            await app.connect(founder1).addMilestone(1, "Milestone 1", descIPFSHash, fiveEther,  milestoneDeadline);
            await app.connect(founder1).startFunding(1);            
            // const project = await crowdfundingPlatform.projects(1);        

        });
        it("Can Start an Extension request", async function () {
            // activate the project
            await app.connect(backer1).invest(1,  fiveEther, {value:  fiveEther});
            // request extension
            await app.connect(founder1).requestExtension(1, 0, milestoneDeadline + 86400);
            const voting = await votingPlatform.getVoting(1,0,-1);
            expect(voting.voteType).to.equal(0); //Extension
        });
        it("Backers can vote for/against extension", async function () {
            // activate the project
            // console.log(project.fundingBalance);
            await app.connect(backer1).invest(1,  ethers.parseEther('2'), {value: ethers.parseEther('2')});
            await app.connect(backer2).invest(1,  ethers.parseEther('3'), {value: ethers.parseEther('3')});
            await app.connect(founder1).requestExtension(1, 0, milestoneDeadline + 86400);
            // vote
            await votingPlatform.connect(backer1).vote(1, 0, true);
            let voting = await votingPlatform.getVoting(1,0,-1);
            expect(voting.result).to.equal(0); //pending
            await votingPlatform.connect(backer2).vote(1, 0, false);
            voting = await votingPlatform.getVoting(1,0,-1);
            expect(voting.positives).to.equal( ethers.parseEther('2'));
            expect(voting.negatives).to.equal( ethers.parseEther('3'));
        });
        it("Can't vote if no voting requested", async function () {
            // activate the project
            await app.connect(backer1).invest(1, oneEther, {value: oneEther});
            // vote
            await expect(
                votingPlatform.connect(backer1).vote(1, 0, true)
            ).to.be.revertedWith("No voting has started yet");
        });
        it("Can't vote twice", async function () {
            // activate the project
            await app.connect(backer1).invest(1, fiveEther, {value: fiveEther});
            // request extension
            await app.connect(founder1).requestExtension(1, 0, milestoneDeadline + 86400);
            // vote
            await votingPlatform.connect(backer1).vote(1, 0, true);
            await expect(
                votingPlatform.connect(backer1).vote(1, 0, false)
            ).to.be.revertedWith("Already voted");
        });

        it("NonBackers can't vote", async function () {
            // activate the project
            await app.connect(backer1).invest(1, fiveEther, {value: fiveEther});
            // request extension
            await app.connect(founder1).requestExtension(1, 0, milestoneDeadline + 86400);
            // vote
            await expect(
                votingPlatform.connect(backer2).vote(1, 0, true)
            ).to.be.revertedWith("You have no voting power");
        });  
        it("Deadline should remain before approval", async function () {
            // activate the project
            await app.connect(backer1).invest(1, fiveEther,{value: fiveEther});
            // request extension
            await app.connect(founder1).requestExtension(1, 0, milestoneDeadline + 86400);
            // const project = await app.projects(1);
            const milestone = await app.getMilestone(1, 0);
            expect(milestone.deadline).to.equal(milestoneDeadline);
        });
        it("Extention Appoved if votepower>50%, and deadline is extended", async function () {
            // activate the project
            await app.connect(backer1).invest(1, ethers.parseEther('2'), {value: ethers.parseEther('2')});
            await app.connect(backer2).invest(1, ethers.parseEther('3'), {value: ethers.parseEther('3')});
            // request extension
            await app.connect(founder1).requestExtension(1, 0, milestoneDeadline + 86400);
            // vote
            await votingPlatform.connect(backer1).vote(1, 0, false);
            await votingPlatform.connect(backer2).vote(1, 0, true);
            const voting = await votingPlatform.getVoting(1,0,-1);
            expect(voting.result).to.equal(1); //Approved
            const milestone = await app.getMilestone(1, 0);
            expect(milestone.deadline).to.equal(milestoneDeadline+86400);
        });
        it("Extention Rejected if votepower<=50%, and deadline is extended", async function () {
            // activate the project
            await app.connect(backer1).invest(1, ethers.parseEther('2.5'), {value: ethers.parseEther('2.5')});
            await app.connect(backer2).invest(1, ethers.parseEther('2.5'), {value: ethers.parseEther('2.5')});
            // request extension
            await app.connect(founder1).requestExtension(1, 0, milestoneDeadline + 86400);
            // vote
            await votingPlatform.connect(backer1).vote(1, 0, false);
            await votingPlatform.connect(backer2).vote(1, 0, true);
            let voting = await votingPlatform.getVoting(1,0,-1);
            expect(voting.result).to.equal(2); //rejected
            let milestone = await app.getMilestone(1, 0);
            expect(milestone.deadline).to.equal(milestoneDeadline);
        });
        it("Can't Start an Extension request if not founder", async function () {
            await app.connect(backer1).invest(1, ethers.parseEther('5'), {value: ethers.parseEther('5')});
            await expect(
                app.connect(founder2).requestExtension(1, 0, milestoneDeadline + 86400)
            ).to.be.revertedWith("Only the founder can perform this action");
        });
        it("Can's Start an Extension request if project not active", async function () {
            await expect(
                app.connect(founder1).requestExtension(1, 0, milestoneDeadline + 86400)
            ).to.be.revertedWith("Project is not active");
        });

    });
    describe("Milestone Advance", function () {
        //TODO: add tests for milestone advance
        
        
        
    });

});
