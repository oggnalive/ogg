# Libraries

| Name                     | Description |
|--------------------------|-------------|
| *liboggnalive_cli*         | RPC client functionality used by *oggnalive-cli* executable |
| *liboggnalive_common*      | Home for common functionality shared by different executables and libraries. Similar to *liboggnalive_util*, but higher-level (see [Dependencies](#dependencies)). |
| *liboggnalive_consensus*   | Stable, backwards-compatible consensus functionality used by *liboggnalive_node* and *liboggnalive_wallet* and also exposed as a [shared library](../shared-libraries.md). |
| *liboggnaliveconsensus*    | Shared library build of static *liboggnalive_consensus* library |
| *liboggnalive_kernel*      | Consensus engine and support library used for validation by *liboggnalive_node* and also exposed as a [shared library](../shared-libraries.md). |
| *liboggnaliveqt*           | GUI functionality used by *oggnalive-qt* and *oggnalive-gui* executables |
| *liboggnalive_ipc*         | IPC functionality used by *oggnalive-node*, *oggnalive-wallet*, *oggnalive-gui* executables to communicate when [`--enable-multiprocess`](multiprocess.md) is used. |
| *liboggnalive_node*        | P2P and RPC server functionality used by *oggnalived* and *oggnalive-qt* executables. |
| *liboggnalive_util*        | Home for common functionality shared by different executables and libraries. Similar to *liboggnalive_common*, but lower-level (see [Dependencies](#dependencies)). |
| *liboggnalive_wallet*      | Wallet functionality used by *oggnalived* and *oggnalive-wallet* executables. |
| *liboggnalive_wallet_tool* | Lower-level wallet functionality used by *oggnalive-wallet* executable. |
| *liboggnalive_zmq*         | [ZeroMQ](../zmq.md) functionality used by *oggnalived* and *oggnalive-qt* executables. |

## Conventions

- Most libraries are internal libraries and have APIs which are completely unstable! There are few or no restrictions on backwards compatibility or rules about external dependencies. Exceptions are *liboggnalive_consensus* and *liboggnalive_kernel* which have external interfaces documented at [../shared-libraries.md](../shared-libraries.md).

- Generally each library should have a corresponding source directory and namespace. Source code organization is a work in progress, so it is true that some namespaces are applied inconsistently, and if you look at [`liboggnalive_*_SOURCES`](../../src/Makefile.am) lists you can see that many libraries pull in files from outside their source directory. But when working with libraries, it is good to follow a consistent pattern like:

  - *liboggnalive_node* code lives in `src/node/` in the `node::` namespace
  - *liboggnalive_wallet* code lives in `src/wallet/` in the `wallet::` namespace
  - *liboggnalive_ipc* code lives in `src/ipc/` in the `ipc::` namespace
  - *liboggnalive_util* code lives in `src/util/` in the `util::` namespace
  - *liboggnalive_consensus* code lives in `src/consensus/` in the `Consensus::` namespace

## Dependencies

- Libraries should minimize what other libraries they depend on, and only reference symbols following the arrows shown in the dependency graph below:

<table><tr><td>

```mermaid

%%{ init : { "flowchart" : { "curve" : "basis" }}}%%

graph TD;

oggnalive-cli[oggnalive-cli]-->liboggnalive_cli;

oggnalived[oggnalived]-->liboggnalive_node;
oggnalived[oggnalived]-->liboggnalive_wallet;

oggnalive-qt[oggnalive-qt]-->liboggnalive_node;
oggnalive-qt[oggnalive-qt]-->liboggnaliveqt;
oggnalive-qt[oggnalive-qt]-->liboggnalive_wallet;

oggnalive-wallet[oggnalive-wallet]-->liboggnalive_wallet;
oggnalive-wallet[oggnalive-wallet]-->liboggnalive_wallet_tool;

liboggnalive_cli-->liboggnalive_util;
liboggnalive_cli-->liboggnalive_common;

liboggnalive_common-->liboggnalive_consensus;
liboggnalive_common-->liboggnalive_util;

liboggnalive_kernel-->liboggnalive_consensus;
liboggnalive_kernel-->liboggnalive_util;

liboggnalive_node-->liboggnalive_consensus;
liboggnalive_node-->liboggnalive_kernel;
liboggnalive_node-->liboggnalive_common;
liboggnalive_node-->liboggnalive_util;

liboggnaliveqt-->liboggnalive_common;
liboggnaliveqt-->liboggnalive_util;

liboggnalive_wallet-->liboggnalive_common;
liboggnalive_wallet-->liboggnalive_util;

liboggnalive_wallet_tool-->liboggnalive_wallet;
liboggnalive_wallet_tool-->liboggnalive_util;

classDef bold stroke-width:2px, font-weight:bold, font-size: smaller;
class oggnalive-qt,oggnalived,oggnalive-cli,oggnalive-wallet bold
```
</td></tr><tr><td>

**Dependency graph**. Arrows show linker symbol dependencies. *Consensus* lib depends on nothing. *Util* lib is depended on by everything. *Kernel* lib depends only on consensus and util.

</td></tr></table>

- The graph shows what _linker symbols_ (functions and variables) from each library other libraries can call and reference directly, but it is not a call graph. For example, there is no arrow connecting *liboggnalive_wallet* and *liboggnalive_node* libraries, because these libraries are intended to be modular and not depend on each other's internal implementation details. But wallet code is still able to call node code indirectly through the `interfaces::Chain` abstract class in [`interfaces/chain.h`](../../src/interfaces/chain.h) and node code calls wallet code through the `interfaces::ChainClient` and `interfaces::Chain::Notifications` abstract classes in the same file. In general, defining abstract classes in [`src/interfaces/`](../../src/interfaces/) can be a convenient way of avoiding unwanted direct dependencies or circular dependencies between libraries.

- *liboggnalive_consensus* should be a standalone dependency that any library can depend on, and it should not depend on any other libraries itself.

- *liboggnalive_util* should also be a standalone dependency that any library can depend on, and it should not depend on other internal libraries.

- *liboggnalive_common* should serve a similar function as *liboggnalive_util* and be a place for miscellaneous code used by various daemon, GUI, and CLI applications and libraries to live. It should not depend on anything other than *liboggnalive_util* and *liboggnalive_consensus*. The boundary between _util_ and _common_ is a little fuzzy but historically _util_ has been used for more generic, lower-level things like parsing hex, and _common_ has been used for oggnalive-specific, higher-level things like parsing base58. The difference between util and common is mostly important because *liboggnalive_kernel* is not supposed to depend on *liboggnalive_common*, only *liboggnalive_util*. In general, if it is ever unclear whether it is better to add code to *util* or *common*, it is probably better to add it to *common* unless it is very generically useful or useful particularly to include in the kernel.


- *liboggnalive_kernel* should only depend on *liboggnalive_util* and *liboggnalive_consensus*.

- The only thing that should depend on *liboggnalive_kernel* internally should be *liboggnalive_node*. GUI and wallet libraries *liboggnaliveqt* and *liboggnalive_wallet* in particular should not depend on *liboggnalive_kernel* and the unneeded functionality it would pull in, like block validation. To the extent that GUI and wallet code need scripting and signing functionality, they should be get able it from *liboggnalive_consensus*, *liboggnalive_common*, and *liboggnalive_util*, instead of *liboggnalive_kernel*.

- GUI, node, and wallet code internal implementations should all be independent of each other, and the *liboggnaliveqt*, *liboggnalive_node*, *liboggnalive_wallet* libraries should never reference each other's symbols. They should only call each other through [`src/interfaces/`](`../../src/interfaces/`) abstract interfaces.

## Work in progress

- Validation code is moving from *liboggnalive_node* to *liboggnalive_kernel* as part of [The liboggnalivekernel Project #24303](https://github.com/oggnalive/oggnalive/issues/24303)
- Source code organization is discussed in general in [Library source code organization #15732](https://github.com/oggnalive/oggnalive/issues/15732)
