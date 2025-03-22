// const { expect } = require("chai");
// const { ethers } = require("hardhat");

// describe("CrowdfundingPlatform", function () {
//   let crowdfundingPlatform;
//   let plaftformOwner;
//   let founder;
//   let backer1;
//   let backer2;
    
// // for CFDToken test, CFDToken.sol?
// //   let cfdTokenAddress;       
  
//   // Project parameters
//   const projectGoal = ethers.parseEther("10");
//   const oneEther = ethers.parseEther("1");
//   const halfEther = ethers.parseEther("0.5");
    
//   let projectDeadline;
  
//   beforeEach(async function () {
//     [plaftformOwner, founder, backer1, backer2] = await ethers.getSigners();
    
//     // Current time + 1 day in seconds
//     projectDeadline = Math.floor(Date.now() / 1000) + 86400; 
    
//     // cfdTokenAddress = "0x1234";
    
//       // crowdfundingPlatform = await ethers.deployContract("CrowdfundingPlatform", [cfdTokenAddress]);
//       crowdfundingPlatform = await ethers.deployContract("CrowdfundingPlatform");

//   });
  
//   describe("Deployment", function () {
//     it("Should set the correct platform plaftformOwner", async function () {
//       expect(await crowdfundingPlatform.platformOwner()).to.equal(plaftformOwner.address);
//     });
    
//     it("Should set the correct platform fee", async function () {
//       expect(await crowdfundingPlatform.PLATFORM_FEE_PERCENT()).to.equal(1);
//     });
//   });
  
//   describe("Project creation", function () {
//       it("Should create a project with correct parameters", async function () {
//         // No project yet
//         expect(await crowdfundingPlatform.projectCount()).to.equal(0);
          
//         // create a project
//         await expect(crowdfundingPlatform.connect(founder).createProject(
//             projectGoal, 
//             projectDeadline
//         ))
//             .to.emit(crowdfundingPlatform, "ProjectCreated")
//             .withArgs(1, founder.address, projectGoal, projectDeadline);
        
//         // check project count increased
//         expect(await crowdfundingPlatform.projectCount()).to.equal(1);
        
//         // Get project details
//         const project = await crowdfundingPlatform.projects(1);
        
//         // Verify project details
//         expect(project.founder).to.equal(founder.address);
//         expect(project.goal).to.equal(projectGoal);
//         expect(project.funded).to.equal(0);
//         expect(project.status).to.equal(0); // ProjectStatus.Active = 0
//         expect(project.deadline).to.equal(projectDeadline);
//     });
    
//     it("Should revert if deadline is in the past", async function () {
//       const pastDeadline = Math.floor(Date.now() / 1000) - 1000; // Past timestamp
      
//       await expect(
//         crowdfundingPlatform.connect(founder).createProject(projectGoal, pastDeadline)
//       ).to.be.revertedWith("Deadline must be in the future");
//     });
    
//     it("Should revert if goal is zero", async function () {
//       await expect(
//         crowdfundingPlatform.connect(founder).createProject(0, projectDeadline)
//       ).to.be.revertedWith("Goal must be a positive number");

//       await expect(
//         crowdfundingPlatform.connect(founder).createProject(-2, projectDeadline)
//       ).to.be.revertedWith("Goal must be a positive number");
//     });
//   });
  
//   describe("Project investment", function () {
//     beforeEach(async function () {
//       // create a project
//       await crowdfundingPlatform.connect(founder).createProject(
//         projectGoal, 
//         projectDeadline
//       );
//     });
    
//     it("Should allow invest to an active project", async function () {
//       await expect(crowdfundingPlatform.connect(backer1).invest(1, oneEther, { value: oneEther }))
//         .to.emit(crowdfundingPlatform, "InvestmentMade")
//         .withArgs(1, backer1.address, oneEther);
      
//       // check project funded amount
//       const project = await crowdfundingPlatform.projects(1);
//       expect(project.funded).to.equal(oneEther);
//       expect(project.totalInvestors).to.equal(1);
//     });
    
//     it("Should allow multiple investments from the same backer", async function () {
//       await crowdfundingPlatform.connect(backer1).invest(1, oneEther, { value: oneEther });
//       await crowdfundingPlatform.connect(backer1).invest(1, oneEther, { value: oneEther });
      
//       // check project funded amount
//       const project = await crowdfundingPlatform.projects(1);
//       expect(project.funded).to.equal(ethers.parseEther("2"));
//       expect(project.totalInvestors).to.equal(1);     // same investor

//       // check backer info of this project
//       const investment = await crowdfundingPlatform.getInvestments(1, backer1);
//       expect(investment).to.equal(ethers.parseEther("2"));

//       const reported = await crowdfundingPlatform.getReported(1, backer1);
//       expect(reported).to.equal(false); 

//     });
    
//     it("Should revert if specified investing amount doesn't match sent value", async function () {
//       await expect(
//         crowdfundingPlatform.connect(backer1).invest(1, oneEther, { value: halfEther })
//       ).to.be.revertedWith("Send exact amount");
//     });
    
//     it("Should revert if project is not active", async function () {
//       // Set the project to approved = 1 (active = 0)
//       await crowdfundingPlatform.setProjectApproved(1);
      
//       await expect(
//         crowdfundingPlatform.connect(backer1).invest(1, oneEther, { value: oneEther })
//       ).to.be.revertedWith("Project is not active");
//     });
//   });
  
//   describe("Project status updates", function () {
//     beforeEach(async function () {
//       // create a project
//       await crowdfundingPlatform.connect(founder).createProject(
//         projectGoal, 
//         projectDeadline
//       );
//     });
    
//     it("Should change project status to Approved", async function () {
//       await expect(crowdfundingPlatform.setProjectApproved(1))
//         .to.emit(crowdfundingPlatform, "ProjectStatusUpdated")
//         .withArgs(1, 1); // 1 = ProjectStatus.Approved
      
//       const project = await crowdfundingPlatform.projects(1);
//       expect(project.status).to.equal(1); // ProjectStatus.Approved
//     });
    
//     it("Should change project status to Failed", async function () {
//       await expect(crowdfundingPlatform.setProjectFailed(1))
//         .to.emit(crowdfundingPlatform, "ProjectStatusUpdated")
//         .withArgs(1, 2); // 2 is ProjectStatus.Failed
      
//       const project = await crowdfundingPlatform.projects(1);
//       expect(project.status).to.equal(2); // ProjectStatus.Failed
//     });
    
//     it("Should revert if project is not active when updating status", async function () {
//       // first set the project to approved
//       await crowdfundingPlatform.setProjectApproved(1);
      
//       // then set to failed
//       await expect(
//         crowdfundingPlatform.setProjectFailed(1)
//       ).to.be.revertedWith("Project not active");
//     });
//   });
  
//   describe("Fund withdrawal", function () {
//     beforeEach(async function () {
//       // create a project
//       await crowdfundingPlatform.connect(founder).createProject(
//         projectGoal, 
//         projectDeadline
//       );
      
//       // Fully fud the project to goal (1=1)
//       await crowdfundingPlatform.connect(backer1).invest(1, projectGoal, { value: projectGoal });
      
//       // Approve the project
//       await crowdfundingPlatform.setProjectApproved(1);
//     });
    
//     it("Should allow founder to withdraw funds after approval", async function () {
//       const initialFounderBalance = await ethers.provider.getBalance(founder.address);
//       const initialOwnerBalance = await ethers.provider.getBalance(plaftformOwner.address);
      
//       // txn fee and founder share
//       const projectGoalBigInt = projectGoal;
//       const transactionFee = projectGoalBigInt * BigInt(1) / BigInt(100); // 1% fee
//       const founderShare = projectGoalBigInt - transactionFee;
      
//       // founder withdraws funds
//       const withdrawTx = await crowdfundingPlatform.connect(founder).withdraw(1);
//       const receipt = await withdrawTx.wait();
//       const gasUsed = receipt.gasUsed * receipt.gasPrice;
      
//       // check project status changed to Finished
//       const project = await crowdfundingPlatform.projects(1);
//       expect(project.status).to.equal(3); // ProjectStatus.Finished
//       expect(project.funded).to.equal(0); // Funds should be reset to 0
      
//       // plaftformOwner receives txn fee
//       const finalOwnerBalance = await ethers.provider.getBalance(plaftformOwner.address);
//       expect(finalOwnerBalance - initialOwnerBalance).to.equal(transactionFee);
      
//       // founder received their share (minus gas costs)
//       const finalFounderBalance = await ethers.provider.getBalance(founder.address);
//       expect(finalFounderBalance - initialFounderBalance + gasUsed).to.equal(founderShare);
//     });
    
//     it("Should revert if non-founder tries to withdraw", async function () {
//       await expect(
//         crowdfundingPlatform.connect(backer1).withdraw(1)
//       ).to.be.revertedWith("Only founder can withdraw");
//     });
    
//     it("Should revert if goal not reached", async function () {
//       // new proj w/ a higher goal
//       await crowdfundingPlatform.connect(founder).createProject(
//         ethers.parseEther("20"), 
//         projectDeadline
//       );
      
//       // Fund it partially
//       await crowdfundingPlatform.connect(backer1).invest(2, oneEther, { value: oneEther });
      
//       // Approve it
//       await crowdfundingPlatform.setProjectApproved(2);
      
//       //withdraw
//       await expect(
//         crowdfundingPlatform.connect(founder).withdraw(2)
//       ).to.be.revertedWith("Goal not reached");
//     });
    
//     it("Should revert if project not approved", async function () {
//       // new project
//       await crowdfundingPlatform.connect(founder).createProject(
//         oneEther, 
//         projectDeadline
//       );
      
//       // fund it fully
//       await crowdfundingPlatform.connect(backer1).invest(2, oneEther, { value: oneEther });
      
//       // withdraw w/o approval
//       await expect(
//         crowdfundingPlatform.connect(founder).withdraw(2)
//       ).to.be.revertedWith("Project not approved");
//     });
//   });
  

  
//   describe("Plaftform owner transfer", function () {
//     it("Should allow platform owner to transfer ownership", async function () {
//       await expect(crowdfundingPlatform.connect(plaftformOwner).updatePlatformOwner(backer1.address))
//         .to.emit(crowdfundingPlatform, "PlatformOwnerUpdated")
//         .withArgs(plaftformOwner.address, backer1.address);
      
//       expect(await crowdfundingPlatform.platformOwner()).to.equal(backer1.address);
//     });
    
//     it("Should revert if non-plaftformowner tries to transfer ownership", async function () {
//       await expect(
//         crowdfundingPlatform.connect(backer1).updatePlatformOwner(backer2.address)
//       ).to.be.revertedWith("Not the platform owner");
//     });
    
//     it("Should revert if transfer ownership to zero address", async function () {
//       await expect(
//         crowdfundingPlatform.connect(plaftformOwner).updatePlatformOwner(ethers.ZeroAddress)
//       ).to.be.revertedWith("Invalid address");
//     });
//   });
  
// });