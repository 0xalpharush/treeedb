contract Test { 
	mapping(uint => uint) splits;
	mapping(uint => uint) deposits;
	mapping(uint => address payable) payee1;
	mapping(uint => address payable) payee2;
	uint lock;
	modifier locked() {
		require(lock == 0);
		lock = 1;
		_;
		lock = 0;
	}
	modifier nonReentrant() {
		lock = 1;
		_;
		lock = 0;
	}
	function updateSplit(uint id, uint split) locked public{
		require(split <= 100);
		splits[id] = split;
	}
	// [Step 1]: Set split of ’a’ (id = 0) to 100(%)
        // [Step 4]: Set split of ’a’ (id = 0) to 0(%)
	function splitFunds(uint id) public nonReentrant {
		address payable a = payee1[id];
		address payable b = payee2[id];
		uint depo = deposits[id];
		deposits[id] = 0;

                // [Step 2]: Transfer 100% fund to ’a’
                // [Step 3]: Reenter updateSplit
		a.call{value:(depo * splits[id] / 100)}("");
                 
                 // [Step 5]: Transfer 100% fund to ’b’
		b.transfer(depo * (100 - splits[id]) / 100);

		p();
		d();
 	}
	function p() private {
	}
	function d() private {
		p();

	}
}