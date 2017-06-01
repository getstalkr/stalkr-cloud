//
//  LinuxMain.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 6/1/17.
//
//

import XCTest

@testable import StalkrCloudTests

XCTMain([
    testCase(UserControllerTests.allTests),
    testCase(TeamControllerTests.allTests),
    testCase(TeamMembershipControllerTests.allTests),
    testCase(RoleControllerTests.allTests),
    testCase(RoleAssignmentControllerTests.allTests),
    testCase(UserTests.allTests),
    testCase(TeamTests.allTests)
    ])
