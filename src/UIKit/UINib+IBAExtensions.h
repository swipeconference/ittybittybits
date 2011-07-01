//
//  UINib+IBAExtensions.h
//  IttyBittyBits
//
//  Created by Oliver Jones on 30/06/11.
//  Copyright 2011 Itty Bitty Apps Pty. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINib (IBAExtensions)

- (UITableViewCell*) instantiateWithOwner:(id)ownerOrNil forTableViewCellWithReuseIdentifier:(NSString*)reuseIdentifier;

@end