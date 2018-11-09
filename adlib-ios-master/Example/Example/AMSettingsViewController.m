//
//  AMSettingsViewController.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMSettingsViewController.h"
#import <Adlib/Adlib.h>

XLFormOptionsObject *XLFormOptionsObjectForGender(AMDemographicsGender gender) {
    switch (gender) {
        case AMDemographicsGenderUndefined: return  [XLFormOptionsObject formOptionsObjectWithValue:@(AMDemographicsGenderUndefined) displayText:@""];
        case AMDemographicsGenderMale: return [XLFormOptionsObject formOptionsObjectWithValue:@(AMDemographicsGenderMale) displayText:@"Male"];
        case AMDemographicsGenderFemale: return[XLFormOptionsObject formOptionsObjectWithValue:@(AMDemographicsGenderFemale) displayText:@"Female"];
    }
}

@interface AMSettingsViewController() <UITableViewDataSource, UITableViewDelegate>

@end

@implementation AMSettingsViewController

#pragma mark - Initializer

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeForm];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeForm];
    }
    return self;
}

- (void)initializeForm {
    
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"Settings"];
    
    
    
    XLFormSectionDescriptor *networksSection = [XLFormSectionDescriptor formSectionWithTitle:@"Banner"];
    
    XLFormRowDescriptor *unitIdRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"unitId" rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Unit ID"];
    [networksSection addFormRow:unitIdRow];
    
    XLFormRowDescriptor *bannerNetworksRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"banners" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Ad Networks"];
    [networksSection addFormRow:bannerNetworksRow];

    [form addFormSection:networksSection];
    
    XLFormSectionDescriptor *demographicsSection = [XLFormSectionDescriptor formSectionWithTitle:@"Demographics"];
    XLFormRowDescriptor *ageRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"age" rowType:XLFormRowDescriptorTypeInteger title:@"Age"];
    [demographicsSection addFormRow:ageRow];
    
    XLFormRowDescriptor *genderRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"gender" rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Gender"];
    genderRow.selectorOptions = @[
        XLFormOptionsObjectForGender(AMDemographicsGenderUndefined),
        XLFormOptionsObjectForGender(AMDemographicsGenderMale),
        XLFormOptionsObjectForGender(AMDemographicsGenderFemale)
    ];
    [demographicsSection addFormRow:genderRow];
    
    XLFormRowDescriptor *geoRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"geo" rowType:XLFormRowDescriptorTypeInfo title:@"Country"];
    [demographicsSection addFormRow:geoRow];
    [form addFormSection:demographicsSection];
    
    self.form = form;
}

#pragma mark - View controller lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    AdlibClient *client = [AdlibClient sharedClient];
    NSMutableArray *bannerOptions = [NSMutableArray new];
    NSMutableArray *bannerValues = [NSMutableArray new];
    NSArray *availableNetworks = client.availableProviders;
    for (AMProvider *provider in availableNetworks) {
        [bannerOptions addObject:provider.name];
        if ([client isProviderEnabled:provider.type]) {
            [bannerValues addObject:provider.name];
        }
    }
    
    XLFormRowDescriptor *bannerNetworksRow = [self.form formRowWithTag:@"banners"];
    bannerNetworksRow.selectorOptions = bannerOptions;
    bannerNetworksRow.value = bannerValues;
    
    XLFormRowDescriptor *unitIdRow = [self.form formRowWithTag:@"unitId"];
    unitIdRow.selectorOptions = client.currentUnitIds;
    unitIdRow.value = self.bannerView.unitId;
    
    XLFormRowDescriptor *ageRow = [self.form formRowWithTag:@"age"];
    ageRow.value = client.demographics.age;
    XLFormRowDescriptor *genderRow = [self.form formRowWithTag:@"gender"];
    genderRow.value = XLFormOptionsObjectForGender(client.demographics.gender);
    XLFormRowDescriptor *geoRow = [self.form formRowWithTag:@"geo"];
    geoRow.value = client.demographics.country;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)doneButtonTapped:(id)sender {
    [self.view endEditing:YES];
    
    NSDictionary *formValues = self.formValues;
    AdlibClient *client = [AdlibClient sharedClient];
    
    NSArray *banners = formValues[@"banners"] ?: @[];
    NSArray *availableNetworks = client.availableProviders;
    for (AMProvider *provider in availableNetworks) {
        [client setProvider:provider.type enabled:[banners containsObject:provider.name]];
    }
    
    NSNumber *age = [formValues[@"age"] isKindOfClass:[NSNull class]] ? nil : formValues[@"age"];
    [client setAge:age];
    XLFormOptionsObject *genderOption = formValues[@"gender"];
    AMDemographicsGender gender = (AMDemographicsGender)[genderOption.valueData unsignedIntegerValue];
    [client setGender:gender];
    
    self.bannerView.unitId = formValues[@"unitId"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.bannerView removeAd];
        [self.bannerView loadAd];
    }];
}

@end
