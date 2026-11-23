# NOTE: readme.txt contains important information you need to take into account
# before running this suite.

*** Settings ***
Library                    QForce
Resource                   ../resources/common.robot
Suite Setup                Setup Browser
Suite Teardown             End suite


*** Variables ***
${username}                # SHOULD BE GIVEN IN CRT VARIABLES SECTION
${password}                # SHOULD BE GIVEN IN CRT SENSITIVE VARIABLES SECTION
${login_url}               # SHOULD BE GIVEN IN CRT VARIABLES SECTION              # Salesforce instance. NOTE: Should be overwritten in CRT variables
${jwt_client_id}           # SHOULD BE GIVEN IN CRT SENSITIVE VARIABLES SECTION
${private_key}             # SHOULD BE GIVEN IN CRT SENSITIVE VARIABLES SECTION
${secret}                  ${NONE}                     # SHOULD BE GIVEN IN CRT SENSITIVE VARIABLES SECTION IF NON-ADMIN (OTP) MFA IS NEEDED


*** Test Cases ***
Entering A Lead
    [tags]                 Lead
    #Appstate              Home
    JwtAuthenticate        ${jwt_client_id}            ${username}                 ${private_key}         sandbox=true
    JwtLoginAs             ethan.trainor@happy-or-not.com.fullcopy
    LaunchApp              HON Sales (Lightning)
    ClickText              Leads
    VerifyText             Change Owner
    ClickText              New                         partial_match=False
    VerifyText             General Information
    UseModal               On                          # Only find fields from open modal dialog
    ${FirstName}           First Name
    ${LastName}            Last Name
    ${Company}             Company

    Picklist               Salutation                  Dr.
    TypeText               First Name                  ${FirstName}
    TypeText               Last Name                   ${LastName}
    Picklist               Lead Status                 Open, to be contacted
    # generate random phone number, just as an example
    # NOTE: initialization of random number generator is done on suite setup
    ${rand_phone}=         Generate Random String      14                          [NUMBERS]
    # concatenate leading "+" and random numbers
    ${phone}=              SetVariable                 +${rand_phone}
    TypeText               Phone                       ${phone}                    First Name
    TypeText               Company                     ${Company}                  Last Name
    TypeText               Title                       Manager                     Address Information
    TypeText               Email                       ${FirstName}.${LastName}@gmail.com                 Website
    TypeText               Website                     https://www.${Company}.com/

    #PickList              Country                     Brazil
    ${Country}             Random Picklist             Country
    Set Suite Variable     ${Country}
    Random PickList        Main Industry
    Random PickList        Sector


    Picklist               Source                      Clay
    ClickText              Save                        partial_match=False
    UseModal               Off
    VerifyText             was created

    # ClickText            Details
    VerifyField            Name                        Dr. ${FirstName} ${LastName}
    VerifyField            Lead Status                 Open, to be contacted
    VerifyField            Phone                       ${phone}
    VerifyField            Company                     ${Company}
    ${CompanyTrim}         Remove String               ${Company}                  ${SPACE}               ,
    VerifyField            Website                     https://www.${Company}.com/
    ${Email}               Convert To Lower Case       ${FirstName}.${LastName}@gmail.com
    VerifyField            Email                       ${Email}

    # as an example, let's check Phone number format. Should be "+" and 14 numbers
    ${phone_num}=          GetFieldValue               Phone
    Should Match Regexp    ${phone_num}                ^[+]\\d{14}$
    ${LeadId}              get record id from url
    Set Suite Variable     ${LeadId}
    # GoToRecord           ${LeadId}

    # just an example of using DateTime Library, let's just log today's date on the Log
    # ${date} =            Get Current Date
    # Log                  Test run on: ${date}


    #                      DeleteRecord                Lead                        ${LeadId}

Converting Lead
    [Documentation]        HON Lead conversion
    [Tags]                 Lead                        Regression
    JwtAuthenticate        ${jwt_client_id}            ${username}                 ${private_key}         sandbox=true
    JwtLoginAs             ethan.trainor@happy-or-not.com.fullcopy
    GoToRecord             ${LeadId}
    VerifyText             Convert To Oppo

    #Conver to Oppo flow

    ClickText              Convert To Oppo
    VerifyText             Does an Contact exist already for this Lead?
    ClickText              Next
    VerifyText             Does an Account exist already for this Lead?
    PickList               *Main Industry               Other
    Picklist               Sector                       Other
    Picklist               *HON Account Size (Override)      Medium
    ClickText              Next

    VerifyText             You are about to convert a Lead to an Opportunity.
    TypeText               *Nr of Months               12
    ${CloseDate}           Get Current Date            increment=15 days           result_format=%b %-d, %Y
    TypeText               Estimated Close Date        ${CloseDate}\t 
    ${StartDate}           Get Current Date            increment=15 days           result_format=%b %-d, %Y
    PressKey               ${EMPTY}                    {TAB}
    PressKey               ${EMPTY}                    {TAB}
    TypeText               Service Start Date          ${StartDate}\t
    ClickItem              20                        tag=td/span
    # ClickText              Select a date for Estimated Close Date
    

    # ClickText    Next Month

    ClickText              Mutual Interest             anchor=Stage
    ClickText              Mutual Interest             anchor=Measurement Type
    ClickText              New Rollout                 anchor=Service Type
    ClickText              New Rollout                 anchor=Back
    ClickText              Convert
    VerifyText             Lead successfully updated
    ClickText              Updating Lead before Conversion
    VerifyText             Lead converted successfully
    ClickText              Converting Lead
    VerifyText             Opportunity updated successfully
    ClickText              Updating Opportunity after Conversion
    VerifyText             Account updated successfully
    ClickText              Updating Account after Conversion
    ClickText              Done
    VerifyText             Related List Quick Links
    VerifyStage            Mutual Interest
    VerifyStageColor       Mutual Interest             navy
    VerifyField            Opportunity Name            Young-Hayes                 partial_match=True
    VerifyField            Opportunity Record Type     General - New Business      partial_match=True
    VerifyField            Opportunity Currency        USD - U.S. Dollar           partial_match=True
    VerifyField            Close Date                  11/21/2026                  partial_match=True
    ClickText              Convert To Oppo
    #Validate Pricebook for Opportunity


Edit Opportunity
    [Documentation]        HON Opportunity Edit
    [Tags]                 Opportunity
    # Add selection of opportunity ID to previous test and add here and validate

    ClickText    Edit
    UseModal    On
    TypeText    Forecast ARR    15000
    ClickText    Select a date for Close Date    anchor=Ready for Renewal
    TypeText    Description    Here should be original customer message from Lea
    TypeText    \#Nr of Smiley Device Subscriptions    4    anchor=Numbers
    ClickText    Save    partial_match=False
    UseModal    Off


Create Quote for Existing Opportunity
    [Documentation]    Create Quote (Standard)
    [Tags]             Quote(Standard)
    # Create quote for existing opportunity from previous step. Add Oppo ID from variable
    #Confirming correct pricebooc for first test
    VerifyText    Mccarthy, White and Lewis
     
    ClickText    Edit Price Book
    ClickText    Clear Price Book Selection
    ComboBox    Search Price Books...    STANDARD-USD
    ClickText    Save
    #Create Quote

  

    ClickText    Create Quote
    UseModal    On
    VerifyText    Select Delivery Option
    ClickText    One shipping address for all items
    ClickText    Continue
    VerifyText    Selected Products
    ClickText    Add Product
    VerifyText    Main Product
    ClickText    Main Product
    ClickText    Next    partial_match=False
    VerifyText    Select Main Product
    VerifyText    Smiley Touch Pipe Leg
    ClickText    Smiley Touch Pipe Leg
    ClickText    Next    partial_match=False
    VerifyText    Select Subproducts
    ClickText    Add    partial_match=False
    VerifyText    Create Quote
    VerifyText    Selected Products
    ClickText    Save Quote
    UseModal    Off
