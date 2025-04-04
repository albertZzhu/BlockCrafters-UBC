const { expect } = require("chai");
const { ethers } = require("hardhat");

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

        
        // console.log("CrowdfundingPlatform address:", app.address);
        // votingPlatform = await ethers.deployContract("ProjectVoting", [app.address]);
    });    
    describe("Milestone Extension", function () {
        let project1Address, project1;
        let votingPlatform1;
        beforeEach(async function () {
            await createValidProject(founder1);
            project1Address = await app.projects(1);
            project1 = await ethers.getContractAt("CrowdfundingProject", project1Address);
            await project1.connect(founder1).addMilestone("Milestone 1",descCID,fiveEther,milestoneDeadline)
            await project1.connect(founder1).startFunding();
            votingPlatform = await ethers.getContractAt("ProjectVoting", await project1.votingPlatform());
        });
        it("Can Start an Extension request", async function () {
            // activate the project
            await project1.connect(backer1).invest({value:  fiveEther});
            // request extension
            await project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay);
            const voting = await votingPlatform.getVoting(0,-1);
            expect(voting.voteType).to.equal(0); //Extension
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
        it("Extention Appoved if votepower>50%, and deadline is extended", async function () {
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
        it("Extention Rejected if votepower<=50%, and deadline is extended", async function () {
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
        it("Can's Start an Extension request if project not active", async function () {
            await expect(
                project1.connect(founder1).requestExtension(0, milestoneDeadline + oneDay)
            ).to.be.revertedWith("Project is not active");
        });

    });
    describe("Milestone Advance", function () {
        //TODO: add tests for milestone advance
        
        
        
    });

});
