module jelo_coin::jelo;

use sui::coin::{Self, TreasuryCap};
use sui::balance::{Balance};
use sui::clock::{Clock};
use sui::url::new_unsafe_from_bytes;

const EInvalidAmount: u64 = 0;
const ESupplyExceeded: u64 = 1;
const ETokenLocked: u64 = 2;

public struct JELO has drop {}

public struct MintCapability has key {
  id: UID,
  treasury: TreasuryCap<JELO>,
  total_minted: u64,
}

public struct Locker has key, store {
  id: UID,
  unlock_date: u64,
  balance: Balance<JELO>,
}

//1B JELO
const TOTAL_SUPPLY: u64 = 1_000_000_000_000_000_000;
const INITAL_SUPPLY: u64 = 100_000_000_000_000_000;


fun init(otw: JELO, ctx: &mut TxContext) {
  let (treasury, metadata) = coin::create_currency(
    otw,
    9,
    b"JELO",
    b"JELO",
    b"Meet JELO the cutest jellyfish meme coin floating through the blockchain ocean!",
    option::some(new_unsafe_from_bytes(b"data:image/jpeg;base64,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")),
    ctx
  );

  let mut mint_cap = MintCapability {
    id: object::new(ctx),
    treasury,
    total_minted: 0,
  };

  mint(&mut mint_cap, INITAL_SUPPLY, ctx.sender(), ctx);

  transfer::public_freeze_object(metadata);
  transfer::transfer(mint_cap, ctx.sender());
}

public fun mint(
  mint_cap: &mut MintCapability,
  amount: u64,
  recipient: address,
  ctx: &mut TxContext
) {
  let coin = mint_internal(mint_cap, amount, ctx);
  transfer::public_transfer(coin, recipient);
}

public fun mint_locked(
  mint_cap: &mut MintCapability,
  amount: u64,
  recipient: address,
  duration: u64,
  clock: &Clock,
  ctx: &mut TxContext
) {
  let coin = mint_internal(mint_cap, amount, ctx);
  let start_date = clock.timestamp_ms();
  let unlock_date = start_date + duration;

  let locker = Locker {
    id: object::new(ctx),
    unlock_date,
    balance: coin::into_balance(coin)
  };

  transfer::public_transfer(locker, recipient)
}

entry fun withdraw_locked(locker: Locker, clock: &Clock, ctx: &mut TxContext): u64 {
  let Locker { id, mut balance, unlock_date } = locker;
  assert!(clock.timestamp_ms() >= unlock_date, ETokenLocked);

  let locked_balance_value = balance.value();

  transfer::public_transfer(
    coin::take(&mut balance, locked_balance_value, ctx),
    ctx.sender()
  );

  balance.destroy_zero();
  object::delete(id);

  locked_balance_value
}

fun mint_internal(
  mint_cap: &mut MintCapability,
  amount: u64,
  ctx: &mut TxContext
): coin::Coin<JELO> {
  assert!(amount > 0, EInvalidAmount);
  assert!(mint_cap.total_minted + amount <= TOTAL_SUPPLY, ESupplyExceeded);

  let treasury_cap = &mut mint_cap.treasury;
  let coin = coin::mint(treasury_cap, amount, ctx);

  mint_cap.total_minted = mint_cap.total_minted + amount;
  coin
}

#[test_only]
use sui::test_scenario;
#[test_only]
use sui::clock;

#[test]
fun test_init() {
  let publisher = @0x11;

  let mut scenario = test_scenario::begin(publisher);
  {
    let otw = JELO{};
    init(otw, scenario.ctx());
  };

  scenario.next_tx(publisher);
  {
    let mint_cap = scenario.take_from_sender<MintCapability>();
    let jelo_coin = scenario.take_from_sender<coin::Coin<JELO>>();

    assert!(mint_cap.total_minted == INITAL_SUPPLY, EInvalidAmount);
    assert!(jelo_coin.balance().value() == INITAL_SUPPLY, EInvalidAmount);

    scenario.return_to_sender(jelo_coin);
    scenario.return_to_sender(mint_cap);
  };

  scenario.next_tx(publisher);
  {
    let mut mint_cap = scenario.take_from_sender<MintCapability>();
    
    mint(
      &mut mint_cap,
      900_000_000_000_000_000,
      scenario.ctx().sender(),
      scenario.ctx()
    );

    assert!(mint_cap.total_minted == TOTAL_SUPPLY, EInvalidAmount);

    scenario.return_to_sender(mint_cap);
  };

  scenario.end();
}

#[test]
fun test_lock_tokens() {
  let publisher = @0x11;
  let bob = @0xB0B;

  let mut scenario = test_scenario::begin(publisher);
  {
    let otw = JELO{};
    init(otw, scenario.ctx());
  };

  scenario.next_tx(publisher);
  {
    let mut mint_cap = scenario.take_from_sender<MintCapability>();
    let duration = 5000;
    let test_clock = clock::create_for_testing(scenario.ctx());

    mint_locked(
      &mut mint_cap,
      900_000_000_000_000_000,
      bob,
      duration,
      &test_clock,
      scenario.ctx()
    );

    assert!(mint_cap.total_minted == TOTAL_SUPPLY, EInvalidAmount);
    scenario.return_to_sender(mint_cap);
    test_clock.destroy_for_testing();
  };

  scenario.next_tx(bob);
  {
    let locker = scenario.take_from_sender<Locker>();
    let duration = 5000;
    let mut test_clock = clock::create_for_testing(scenario.ctx());
    test_clock.set_for_testing(duration);

    let amount = withdraw_locked(
      locker,
      &test_clock,
      scenario.ctx()
    );

    assert!(amount == 900_000_000_000_000_000, EInvalidAmount);
    test_clock.destroy_for_testing();
  };

  scenario.next_tx(bob);
  {
    let coin = scenario.take_from_sender<coin::Coin<JELO>>();
    assert!(coin.balance().value() == 900_000_000_000_000_000, EInvalidAmount);
    scenario.return_to_sender(coin);
  };

  scenario.end();
}

#[test]
#[expected_failure(abort_code = ESupplyExceeded)]
fun test_lock_overflow() {
  let publisher = @0x11;
  let bob = @0xB0B;

  let mut scenario = test_scenario::begin(publisher);
  {
    let otw = JELO{};
    init(otw, scenario.ctx());
  };

  scenario.next_tx(publisher);
  {
    let mut mint_cap = scenario.take_from_sender<MintCapability>();
    let duration = 5000;
    let test_clock = clock::create_for_testing(scenario.ctx());

    mint_locked(
      &mut mint_cap,
      900_000_000_000_000_001,
      bob,
      duration,
      &test_clock,
      scenario.ctx()
    );

    scenario.return_to_sender(mint_cap);
    test_clock.destroy_for_testing();
  };

  scenario.end();
}

#[test]
#[expected_failure(abort_code = ESupplyExceeded)]
fun test_mint_overflow() {
  let publisher = @0x11;

  let mut scenario = test_scenario::begin(publisher);
  {
    let otw = JELO{};
    init(otw, scenario.ctx());
  };

  scenario.next_tx(publisher);
  {
    let mut mint_cap = scenario.take_from_sender<MintCapability>();
    
    mint(
      &mut mint_cap,
      900_000_000_000_000_001,
      scenario.ctx().sender(),
      scenario.ctx()
    );

    scenario.return_to_sender(mint_cap);
  };

  scenario.end();
}


#[test]
#[expected_failure(abort_code = ETokenLocked)]
fun test_withdraw_locked_tokens_before_unlock() {
  let publisher = @0x11;
  let bob = @0xB0B;

  let mut scenario = test_scenario::begin(publisher);
  {
    let otw = JELO{};
    init(otw, scenario.ctx());
  };

  scenario.next_tx(publisher);
  {
    let mut mint_cap = scenario.take_from_sender<MintCapability>();
    let duration = 5000;
    let test_clock = clock::create_for_testing(scenario.ctx());

    mint_locked(
      &mut mint_cap,
      900_000_000_000_000_000,
      bob,
      duration,
      &test_clock,
      scenario.ctx()
    );

    assert!(mint_cap.total_minted == TOTAL_SUPPLY, EInvalidAmount);
    scenario.return_to_sender(mint_cap);
    test_clock.destroy_for_testing();
  };

  scenario.next_tx(bob);
  {
    let locker = scenario.take_from_sender<Locker>();
    let duration = 4999;
    let mut test_clock = clock::create_for_testing(scenario.ctx());
    test_clock.set_for_testing(duration);
    
    withdraw_locked(
      locker,
      &test_clock,
      scenario.ctx()
    );

    test_clock.destroy_for_testing();
  };

  scenario.end();
}