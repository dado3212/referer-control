#import <Preferences/PSListController.h>
#import <Preferences/PSEditableListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTextFieldSpecifier.h>
#import "PSTableCell.h"

NSString *prefPath = @"/var/mobile/Library/Preferences/com.hackingdartmouth.referercontrol.plist";

@interface RefererControlListController: PSEditableListController
@end

@interface Referer : PSListController {
  int index;
  NSMutableArray *referers;
}
@end

// CUSTOM CELL
@interface AddCell : PSTableCell
@end

extern NSString *PSDeletionActionKey;

@implementation RefererControlListController

- (void)viewDidLoad {
  NSMutableArray *referers = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
  if (referers == nil)
    referers = [[NSMutableArray alloc] init];
  [referers writeToFile:prefPath atomically:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section != 0)
    return NO;
  else
    return [super tableView:tableView canEditRowAtIndexPath:indexPath];
}

-(id)specifiers {
  if (_specifiers == nil) {
    NSMutableArray *specs = [NSMutableArray array];

    PSSpecifier* group = [PSSpecifier preferenceSpecifierNamed:@"Referers"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSGroupCell
      edit:Nil];
    [group setProperty:@"Create a referer to set the HTTP 'Referer' property for specific URLs" forKey:@"footerText"];
    [specs addObject:group];

    NSArray *referers = [[NSArray alloc] initWithContentsOfFile:prefPath];

    for (int i = 0; i < [referers count]; i++) {
      PSSpecifier* tempSpec = [PSSpecifier preferenceSpecifierNamed:referers[i][1]
                          target:self
                           set:NULL
                           get:NULL
                          detail:NSClassFromString(@"Referer")
                          cell:PSLinkCell
                          edit:Nil];
      [tempSpec setProperty:@(i) forKey:@"arrayIndex"];
      [tempSpec setProperty:NSStringFromSelector(@selector(deleteReferer:)) forKey:PSDeletionActionKey];
      [specs addObject:tempSpec];
    }

    //initialize add button
    PSSpecifier* button = [PSSpecifier preferenceSpecifierNamed:@""
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSButtonCell
      edit:Nil];
    [button setButtonAction:@selector(addReferer)];
    [button setProperty:[AddCell class] forKey:@"cellClass"];
    [specs addObject:button];

    //initialize about
    group = [PSSpecifier preferenceSpecifierNamed:@"About"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSGroupCell
      edit:Nil];

    // Date 2017-current year
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    if ([yearString isEqualToString:@"2017"]) {
      [group setProperty:@"© 2017 Alex Beals" forKey:@"footerText"];
    } else {
      [group setProperty:[NSString stringWithFormat:@"© 2017-%@ Alex Beals", yearString] forKey:@"footerText"];
    }
    
    [group setProperty:@(1) forKey:@"footerAlignment"];
    [specs addObject:group];

    button = [PSSpecifier preferenceSpecifierNamed:@"Donate to Developer"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSButtonCell
      edit:Nil];
    [button setButtonAction:@selector(donate)];
    [button setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/RefererControl.bundle/paypal.png"] forKey:@"iconImage"];
    [specs addObject:button];

    button = [PSSpecifier preferenceSpecifierNamed:@"Source Code on Github"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSButtonCell
      edit:Nil];
    [button setButtonAction:@selector(source)];
    [button setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/RefererControl.bundle/github.png"] forKey:@"iconImage"];
    [specs addObject:button];

    button = [PSSpecifier preferenceSpecifierNamed:@"Email Developer"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSButtonCell
      edit:Nil];
    [button setButtonAction:@selector(email)];
    [button setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/RefererControl.bundle/mail.png"] forKey:@"iconImage"];
    [specs addObject:button];

    _specifiers = [[NSArray arrayWithArray:specs] retain];
  }
  return _specifiers;
}

-(id)getText:(PSSpecifier*)specifier {
  return @"Testing";
}

- (void)deleteReferer:(PSSpecifier *)specifier {
  NSMutableArray *referers = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
  [referers removeObjectAtIndex:([_specifiers indexOfObject:specifier])];
  [referers writeToFile:prefPath atomically:YES];
}

- (void)addReferer {
  NSMutableArray *referers = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
  referers = (referers != nil) ? referers : [[NSMutableArray alloc] init];
  [referers addObject:@[@YES, @"", @""]];
  [referers writeToFile:prefPath atomically:YES];

  [self reloadSpecifiers];
}

-(void)viewWillAppear:(BOOL)arg1 {
  [self reloadSpecifiers];
  [super viewWillAppear:arg1];
}

- (void)source {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/dado3212/RefererControl"]];
}

- (void)donate {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/AlexBeals"]];
}

- (void)email {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:Alex.Beals.18@dartmouth.edu?subject=Cydia%3A%20RefererControl"]];
}
@end

@implementation AddCell

- (id)initWithStyle:(int)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {

  id s = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];

  UIImage *image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/RefererControl.bundle/add.png"];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.frame = CGRectMake(6,self.frame.size.height*(1.0/8.0),self.frame.size.height*(3.0/4.0),self.frame.size.height*(3.0/4.0));

  [s addSubview:imageView];

  UILabel *label = [[UILabel alloc] init];
  label.text = @"Add Referer";
  label.font=[UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  label.textColor = [UIColor colorWithRed:0.0f green:116.0f/255.0f blue:1.0f alpha:1.0f];
  [label sizeToFit];
  label.frame = CGRectMake(45,(self.frame.size.height - label.frame.size.height)/2,label.frame.size.width,label.frame.size.height);

  [s addSubview:label];

  return s;
 }
@end

@implementation Referer
-(void)setSpecifier:(PSSpecifier *)specifier {
  [super setSpecifier:specifier];
  index = [specifier.properties[@"arrayIndex"] intValue];
  referers = [[NSMutableArray alloc] initWithContentsOfFile:prefPath];
}

-(id)specifiers {
  if (_specifiers == nil) {
    NSMutableArray *specs = [NSMutableArray array];
    PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                        target:self
                         set:@selector(setPreferenceValue:specifier:)
                         get:@selector(readPreferenceValue:)
                        detail:Nil
                        cell:PSSwitchCell
                        edit:Nil];
    [specs addObject:spec];

    PSSpecifier* group = [PSSpecifier preferenceSpecifierNamed:@"Referer"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSGroupCell
      edit:Nil];
    [specs addObject:group];

    PSTextFieldSpecifier *textSpec = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Site"
                                          target:self
                                           set:@selector(setPreferenceValue:specifier:)
                                          get:@selector(readPreferenceValue:)
                                         detail:Nil
                                           cell:PSEditTextCell
                                           edit:nil];
    [textSpec setPlaceholder:@"Enter a string to match"];
    [textSpec setKeyboardType:UIKeyboardTypeURL autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];

    [specs addObject:textSpec];

    textSpec = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Referer"
                                          target:self
                                           set:@selector(setPreferenceValue:specifier:)
                                          get:@selector(readPreferenceValue:)
                                         detail:Nil
                                           cell:PSEditTextCell
                                           edit:nil];
    [textSpec setPlaceholder:@"Enter a URL to set the referer to"];
    [textSpec setKeyboardType:UIKeyboardTypeURL autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];

    [specs addObject:textSpec];

    group = [PSSpecifier emptyGroupSpecifier];
    [group setProperty:@"For the site string, you can use * as a wildcard." forKey:@"footerText"];
    [specs addObject:group];

    _specifiers = [[specs copy] retain];
  }
  return _specifiers;
}

-(id)readPreferenceValue:(PSSpecifier*)specifier {
  if ([[specifier name] isEqualToString:@"Enabled"]) {
    return referers[index][0];
  } else if ([[specifier name] isEqualToString:@"Site"]) {
    return referers[index][1];
  } else {
    return referers[index][2];
  }
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
  if ([[specifier name] isEqualToString:@"Enabled"]) {
    referers[index][0] = value;
  } else if ([[specifier name] isEqualToString:@"Site"]) {
    referers[index][1] = value;
  } else {
    referers[index][2] = value;
  }
  [referers writeToFile:prefPath atomically:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
  [self.view endEditing:YES];
  [super viewWillDisappear:animated];
}
@end