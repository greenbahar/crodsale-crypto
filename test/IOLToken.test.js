// const BigNumber = web3.BigNumber;

const IOLToken = artifacts.require('IOLToken');

require('chai')
    // .use(require('chai-bignumber')(BigNumber))
    .should();

contract('IOLToken',accounts => {
    const _initialSupply = 1000;
    const _name = 'IOL';
    const _symbol = 'IOL';

    beforeEach(async function(){
        this.token = await IOLToken.new(_initialSupply,_name,_symbol);
    });

    describe('token attributes', function(){
        it('has the correct name', async function(){
            const name = await this.token.name();
            name.should.equal(_name);
            // assert.equal(name,'IOLT');   //leads err
        });

        it('has the correct symbol', async function(){
            const symbol = await this.token.symbol();
            symbol.should.equal(_symbol);
        });

        // it('has the correct decimal', async function(){
        //     const decimal = await this.token.decimal();
        //     decimal.should.be.bignumber.equal(_decimal);
        // });
    });
});