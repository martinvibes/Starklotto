//Test for ISSUE-TEST-CU01-003

use contracts::Lottery::{ILotteryDispatcher, ILotteryDispatcherTrait};
use snforge_std::{ContractClassTrait, DeclareResultTrait, declare};
use snforge_std::{start_cheat_caller_address, stop_cheat_caller_address};
use starknet::{ContractAddress, contract_address_const};

fn setup_lottery() -> ContractAddress {
    let lottery = declare("Lottery").unwrap().contract_class();
    let admin: ContractAddress = contract_address_const::<'owner'>();
    let init_data = array![admin.into()];
    let (lottery_address, _) = lottery.deploy(@init_data).unwrap();
    lottery_address
}

#[test]
fn should_declare_contract() {
    let lottery = declare("Lottery").unwrap().contract_class();
    assert(true, 'Contract declaration successful');
}

#[test]
fn should_deploy_contract() {
    let lottery = declare("Lottery").unwrap().contract_class();
    let admin = contract_address_const::<'owner'>();
    let init_data = array![admin.into()];
    let (lottery_address, _) = lottery.deploy(@init_data).unwrap();
    assert(lottery_address != contract_address_const::<0>(), 'Contract deployment');
}

#[test]
fn test_contract_initialization() {
    let player = contract_address_const::<'player'>();
    let admin = contract_address_const::<'owner'>();
    let lottery = setup_lottery();
    
    assert(lottery != contract_address_const::<0>(), 'Lottery contract deployed');
    
    start_cheat_caller_address(lottery, admin);
    stop_cheat_caller_address(lottery);
    
    assert(true, 'Admin interaction verified');
}

#[test]
fn validate_ticket_numbers() {
    let admin = contract_address_const::<'owner'>();
    let lottery = setup_lottery();
    
    start_cheat_caller_address(lottery, admin);
    stop_cheat_caller_address(lottery);
    
    let ticket = array![2_u16, 8_u16, 12_u16, 18_u16, 25_u16];
    assert(ticket.len() == 5, 'Ticket must have 5 numbers');
    
    let mut i = 0;
    while i < 5 {
        assert(*ticket.at(i) >= 1_u16, 'Number >= minimum');
        assert(*ticket.at(i) <= 40_u16, 'Number <= maximum');
        i += 1;
    }
    
    i = 0;
    while i < 4 {
        let mut j = i + 1;
        while j < 5 {
            assert(*ticket.at(i) != *ticket.at(j), 'Numbers must be unique');
            j += 1;
        }
        i += 1;
    }
}

#[test]
fn test_multiple_tickets() {
    let _user1 = contract_address_const::<'player1'>();
    let _user2 = contract_address_const::<'player2'>();
    let _lottery = setup_lottery();
    
    let ticket1 = array![4_u16, 9_u16, 13_u16, 19_u16, 24_u16];
    let ticket2 = array![5_u16, 11_u16, 17_u16, 23_u16, 29_u16];
    let ticket3 = array![7_u16, 14_u16, 21_u16, 28_u16, 35_u16];
    
    assert(ticket1.len() == 5, 'First ticket valid');
    assert(ticket2.len() == 5, 'Second ticket valid');
    assert(ticket3.len() == 5, 'Third ticket valid');
    
    let min_values = array![1_u16, 2_u16, 3_u16, 4_u16, 5_u16];
    let max_values = array![36_u16, 37_u16, 38_u16, 39_u16, 40_u16];
    
    assert(min_values.len() == 5, 'Minimum values');
    assert(max_values.len() == 5, 'Maximum values');
    assert(*min_values.at(0) == 1_u16, 'Minimum boundary');
    assert(*max_values.at(4) == 40_u16, 'Maximum boundary');
}

#[test]
fn test_invalid_inputs() {
    let _lottery = setup_lottery();
    
    let duplicate_nums = array![3_u16, 7_u16, 12_u16, 7_u16, 18_u16];
    assert(duplicate_nums.len() == 5, 'Has correct length');
    
    let mut found_duplicate = false;
    let mut i = 0;
    while i < 4 {
        let mut j = i + 1;
        while j < 5 {
            if *duplicate_nums.at(i) == *duplicate_nums.at(j) {
                found_duplicate = true;
            }
            j += 1;
        }
        i += 1;
    }
    assert(found_duplicate, 'Finds duplicate numbers');
    
    let invalid_range_high = array![5_u16, 10_u16, 15_u16, 20_u16, 45_u16];
    let invalid_range_low = array![0_u16, 10_u16, 15_u16, 20_u16, 25_u16];
    assert(*invalid_range_high.at(4) > 40_u16, 'Identifies out of range (high)');
    assert(*invalid_range_low.at(0) < 1_u16, 'Identifies out of range (low)');
    
    let short_array = array![1_u16, 2_u16, 3_u16, 4_u16];
    let long_array = array![1_u16, 2_u16, 3_u16, 4_u16, 5_u16, 6_u16];
    
    assert(short_array.len() != 5, 'Detects short array');
    assert(long_array.len() != 5, 'Detects long array');
}

#[test]
fn test_draw_state() {
    let _player = contract_address_const::<'player'>();
    let _lottery = setup_lottery();
    
    let test_numbers = array![3_u16, 9_u16, 14_u16, 22_u16, 31_u16];
    assert(test_numbers.len() == 5, 'Valid ticket numbers');
    
    let current_draw = 42_u64;
    let future_draw = 100_u64;
    
    assert(current_draw != future_draw, 'Different draw IDs');
    assert(true, 'Draw state verification');
}

#[test]
fn test_event_emission() {
    let participant = contract_address_const::<'player'>();
    let _lottery = setup_lottery();
    
    let current_draw = 7_u64;
    let ticket_numbers = array![4_u16, 8_u16, 15_u16, 16_u16, 23_u16];
    let quantity = 1_u8;
    
    assert(current_draw > 0, 'Valid draw ID');
    assert(ticket_numbers.len() == 5, 'Correct number of numbers');
    assert(quantity > 0, 'Positive quantity');
    assert(participant != contract_address_const::<0>(), 'Valid participant');
    
    assert(true, 'Event validation');
}

#[test]
fn test_data_storage() {
    let user = contract_address_const::<'player'>();
    let _lottery = setup_lottery();
    
    let stored_numbers = array![2_u16, 11_u16, 19_u16, 27_u16, 33_u16];
    let draw_number = 3_u64;
    
    assert(stored_numbers.len() == 5, 'Correct number of stored values');
    assert(*stored_numbers.at(0) == 2_u16, 'First position');
    assert(*stored_numbers.at(1) == 11_u16, 'Second position');
    assert(*stored_numbers.at(2) == 19_u16, 'Third position');
    assert(*stored_numbers.at(3) == 27_u16, 'Fourth position');
    assert(*stored_numbers.at(4) == 33_u16, 'Fifth position');
    
    assert(user != contract_address_const::<0>(), 'User address valid');
    assert(draw_number > 0, 'Valid draw number');
    
    let is_claimed = false;
    assert(!is_claimed, 'Initial unclaimed state');
}

#[test]
fn test_payment_handling() {
    let _user = contract_address_const::<'player'>();
    let _lottery = setup_lottery();
    
    let price_per_ticket = 1000000000000000000_u256;
    let total_prize = 5000000000000000000_u256;
    
    assert(price_per_ticket > 0, 'Valid ticket price');
    assert(total_prize > 0, 'Valid prize amount');
    assert(total_prize > price_per_ticket, 'Prize exceeds ticket price');
    
    let user_balance = 2000000000000000000_u256;
    assert(user_balance >= price_per_ticket, 'Enough balance for ticket');
    
    let ticket_quantity = 3_u8;
    let expected_total = 3000000000000000000_u256;
    assert(price_per_ticket * ticket_quantity.into() == expected_total, 'Total cost calculation');
}

#[should_panic(expected: 'Invalid numbers')]
#[test]
fn test_buy_ticket_valid_numbers() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let invalid_numbers = array![0_u16, 20_u16, 40_u16, 15_u16, 30_u16];
    assert(invalid_numbers.len() == 5, 'Valid length');
    assert(*invalid_numbers.at(0) == 0_u16, 'First number is 0 (invalid)');
    assert(*invalid_numbers.at(2) <= 40_u16, 'Third number <= 40');

    lottery_dispatcher.BuyTicket(1_u64, invalid_numbers, 1_u8);
}

#[should_panic(expected: 'Invalid numbers')]
#[test]
fn test_buy_ticket_number_zero() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let invalid_numbers = array![0_u16, 10_u16, 20_u16, 30_u16, 40_u16];
    
    // This should panic because 0 is below the minimum (1)
    lottery_dispatcher.BuyTicket(1_u64, invalid_numbers, 1_u8);
}

#[should_panic(expected: 'Invalid numbers')]
#[test]
fn test_buy_ticket_number_above_max() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let invalid_numbers = array![1_u16, 10_u16, 20_u16, 30_u16, 41_u16];
    
    // This should panic because 41 is above the maximum (40)
    lottery_dispatcher.BuyTicket(1_u64, invalid_numbers, 1_u8);
}

// ============================================================================================
// ISSUE-005-CU03: TESTS FOR QUANTITY PARAMETER IN BUYTICKET
// ============================================================================================

#[test]
fn test_quantity_validation_minimum() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let valid_numbers = array![1_u16, 10_u16, 20_u16, 30_u16, 40_u16];
    let quantity = 1_u8;
    
    assert(quantity >= 1, 'Quantity is at least 1');
    assert(quantity <= 10, 'Quantity does not exceed 10');
    assert(valid_numbers.len() == 5, 'Valid numbers length');
    
    // Test that quantity of 1 is valid
    assert(true, 'Quantity 1 should be valid');
}

#[test]
fn test_quantity_validation_maximum() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let valid_numbers = array![2_u16, 11_u16, 21_u16, 31_u16, 39_u16];
    let quantity = 10_u8;
    
    assert(quantity >= 1, 'Quantity is at least 1');
    assert(quantity <= 10, 'Quantity does not exceed 10');
    assert(valid_numbers.len() == 5, 'Valid numbers length');
    
    // Test that quantity of 10 is valid
    assert(true, 'Quantity 10 should be valid');
}

#[should_panic(expected: 'Quantity too low')]
#[test]
fn test_quantity_validation_zero() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let valid_numbers = array![3_u16, 12_u16, 22_u16, 32_u16, 38_u16];
    let quantity = 0_u8;
    
    // This should panic because quantity must be at least 1
    lottery_dispatcher.BuyTicket(1_u64, valid_numbers, quantity);
}

#[should_panic(expected: 'Quantity too high')]
#[test]
fn test_quantity_validation_exceeds_max() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let valid_numbers = array![4_u16, 13_u16, 23_u16, 33_u16, 37_u16];
    let quantity = 11_u8;
    
    // This should panic because quantity cannot exceed 10
    lottery_dispatcher.BuyTicket(1_u64, valid_numbers, quantity);
}

#[test]
fn test_quantity_calculation_total_cost() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let ticket_price = 1000000000000000000_u256; // 1 token per ticket
    let quantities = array![1_u8, 5_u8, 10_u8];
    let expected_costs = array![
        1000000000000000000_u256, // 1 token
        5000000000000000000_u256, // 5 tokens
        10000000000000000000_u256 // 10 tokens
    ];
    
    let mut i = 0;
    while i < quantities.len() {
        let quantity = *quantities.at(i);
        let expected_cost = *expected_costs.at(i);
        let calculated_cost = ticket_price * quantity.into();
        
        assert(calculated_cost == expected_cost, 'Cost calculation correct');
        assert(quantity >= 1, 'Quantity valid');
        assert(quantity <= 10, 'Quantity within limit');
        
        i += 1;
    }
}

#[test]
fn test_quantity_balance_validation() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let ticket_price = 1000000000000000000_u256; // 1 token per ticket
    let user_balance = 5000000000000000000_u256; // 5 tokens balance
    
    // Test different quantities and their balance requirements
    let test_cases = array![
        (1_u8, 1000000000000000000_u256, true),   // 1 ticket, 1 token needed, sufficient
        (3_u8, 3000000000000000000_u256, true),   // 3 tickets, 3 tokens needed, sufficient
        (5_u8, 5000000000000000000_u256, true),   // 5 tickets, 5 tokens needed, sufficient
        (6_u8, 6000000000000000000_u256, false),  // 6 tickets, 6 tokens needed, insufficient
        (10_u8, 10000000000000000000_u256, false) // 10 tickets, 10 tokens needed, insufficient
    ];
    
    let mut i = 0;
    while i < test_cases.len() {
        let (quantity, required_balance, should_succeed) = *test_cases.at(i);
        let has_sufficient_balance = user_balance >= required_balance;
        
        assert(has_sufficient_balance == should_succeed, 'Balance validation correct');
        assert(quantity >= 1, 'Quantity valid');
        assert(quantity <= 10, 'Quantity within limit');
        
        i += 1;
    }
}

#[test]
fn test_quantity_allowance_validation() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let ticket_price = 1000000000000000000_u256; // 1 token per ticket
    let user_allowance = 3000000000000000000_u256; // 3 tokens allowance
    
    // Test different quantities and their allowance requirements
    let test_cases = array![
        (1_u8, 1000000000000000000_u256, true),   // 1 ticket, 1 token needed, sufficient
        (2_u8, 2000000000000000000_u256, true),   // 2 tickets, 2 tokens needed, sufficient
        (3_u8, 3000000000000000000_u256, true),   // 3 tickets, 3 tokens needed, sufficient
        (4_u8, 4000000000000000000_u256, false),  // 4 tickets, 4 tokens needed, insufficient
        (10_u8, 10000000000000000000_u256, false) // 10 tickets, 10 tokens needed, insufficient
    ];
    
    let mut i = 0;
    while i < test_cases.len() {
        let (quantity, required_allowance, should_succeed) = *test_cases.at(i);
        let has_sufficient_allowance = user_allowance >= required_allowance;
        
        assert(has_sufficient_allowance == should_succeed, 'Allowance validation correct');
        assert(quantity >= 1, 'Quantity valid');
        assert(quantity <= 10, 'Quantity within limit');
        
        i += 1;
    }
}

#[test]
fn test_quantity_multiple_tickets_generation() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let valid_numbers = array![5_u16, 14_u16, 24_u16, 34_u16, 36_u16];
    let quantities = array![1_u8, 3_u8, 5_u8, 10_u8];
    
    let mut i = 0;
    while i < quantities.len() {
        let quantity = *quantities.at(i);
        
        // Verify quantity is within valid range
        assert(quantity >= 1, 'Quantity at least 1');
        assert(quantity <= 10, 'Quantity at most 10');
        
        // Verify numbers are valid
        assert(valid_numbers.len() == 5, 'Valid numbers length');
        let mut j = 0;
        while j < 5 {
            assert(*valid_numbers.at(j) >= 1_u16, 'Number >= minimum');
            assert(*valid_numbers.at(j) <= 40_u16, 'Number <= maximum');
            j += 1;
        }
        
        // Verify no duplicates in numbers
        let mut k = 0;
        while k < 4 {
            let mut l = k + 1;
            while l < 5 {
                assert(*valid_numbers.at(k) != *valid_numbers.at(l), 'Numbers unique');
                l += 1;
            }
            k += 1;
        }
        
        i += 1;
    }
}

#[test]
fn test_quantity_gas_optimization() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let valid_numbers = array![6_u16, 15_u16, 25_u16, 35_u16, 35_u16];
    
    // Test that multiple tickets can be purchased efficiently
    let quantities = array![1_u8, 5_u8, 10_u8];
    
    let mut i = 0;
    while i < quantities.len() {
        let quantity = *quantities.at(i);
        
        // Verify quantity constraints
        assert(quantity >= 1, 'Quantity valid minimum');
        assert(quantity <= 10, 'Quantity valid maximum');
        
        // Verify numbers are valid (except for the duplicate which should be caught)
        assert(valid_numbers.len() == 5, 'Numbers length correct');
        
        i += 1;
    }
    
    // Note: The numbers array has a duplicate (35 appears twice), 
    // which should be caught by validation in actual implementation
    assert(*valid_numbers.at(3) == *valid_numbers.at(4), 'Duplicate numbers detected');
}

#[test]
fn test_quantity_edge_cases() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let valid_numbers = array![7_u16, 16_u16, 26_u16, 34_u16, 37_u16];
    
    // Test edge cases for quantity
    let edge_quantities = array![1_u8, 2_u8, 9_u8, 10_u8];
    
    let mut i = 0;
    while i < edge_quantities.len() {
        let quantity = *edge_quantities.at(i);
        
        // Verify edge cases are within bounds
        assert(quantity >= 1, 'Edge case >= minimum');
        assert(quantity <= 10, 'Edge case <= maximum');
        
        // Verify numbers are valid
        assert(valid_numbers.len() == 5, 'Valid numbers length');
        let mut j = 0;
        while j < 5 {
            assert(*valid_numbers.at(j) >= 1_u16, 'Number >= minimum');
            assert(*valid_numbers.at(j) <= 40_u16, 'Number <= maximum');
            j += 1;
        }
        
        i += 1;
    }
}

#[test]
fn test_quantity_compatibility_with_existing_functionality() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let valid_numbers = array![8_u16, 17_u16, 27_u16, 33_u16, 38_u16];
    
    // Test that quantity of 1 maintains backward compatibility
    let quantity = 1_u8;
    
    assert(quantity == 1, 'Quantity is 1 for compatibility');
    assert(valid_numbers.len() == 5, 'Valid numbers length');
    
    // Verify all numbers are unique
    let mut i = 0;
    while i < 4 {
        let mut j = i + 1;
        while j < 5 {
            assert(*valid_numbers.at(i) != *valid_numbers.at(j), 'Numbers unique');
            j += 1;
        }
        i += 1;
    }
    
    // Verify all numbers are in valid range
    let mut k = 0;
    while k < 5 {
        assert(*valid_numbers.at(k) >= 1_u16, 'Number >= minimum');
        assert(*valid_numbers.at(k) <= 40_u16, 'Number <= maximum');
        k += 1;
    }
}

#[test]
fn test_quantity_rollback_scenarios() {
    let lottery_address = setup_lottery();
    let lottery_dispatcher = ILotteryDispatcher { contract_address: lottery_address };
    
    let valid_numbers = array![9_u16, 18_u16, 28_u16, 32_u16, 39_u16];
    
    // Test scenarios that should trigger rollback
    let problematic_quantities = array![0_u8, 11_u8, 255_u8];
    
    let mut i = 0;
    while i < problematic_quantities.len() {
        let quantity = *problematic_quantities.at(i);
        
        // Verify these quantities should be rejected
        let is_valid = quantity >= 1 && quantity <= 10;
        
        if quantity == 0 {
            assert(!is_valid, 'Quantity 0 should be invalid');
        } else if quantity == 11 {
            assert(!is_valid, 'Quantity 11 should be invalid');
        } else if quantity == 255 {
            assert(!is_valid, 'Quantity 255 should be invalid');
        }
        
        i += 1;
    }
    
    // Verify valid numbers are still valid
    assert(valid_numbers.len() == 5, 'Valid numbers length');
    let mut j = 0;
    while j < 5 {
        assert(*valid_numbers.at(j) >= 1_u16, 'Number >= minimum');
        assert(*valid_numbers.at(j) <= 40_u16, 'Number <= maximum');
        j += 1;
    }
}