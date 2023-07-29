// Copyright (c) 2011-2020 The Bitcoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef OGGNALIVE_QT_OGGNALIVEADDRESSVALIDATOR_H
#define OGGNALIVE_QT_OGGNALIVEADDRESSVALIDATOR_H

#include <QValidator>

/** Base58 entry widget validator, checks for valid characters and
 * removes some whitespace.
 */
class oggnaliveAddressEntryValidator : public QValidator
{
    Q_OBJECT

public:
    explicit oggnaliveAddressEntryValidator(QObject *parent);

    State validate(QString &input, int &pos) const override;
};

/** oggnalive address widget validator, checks for a valid oggnalive address.
 */
class oggnaliveAddressCheckValidator : public QValidator
{
    Q_OBJECT

public:
    explicit oggnaliveAddressCheckValidator(QObject *parent);

    State validate(QString &input, int &pos) const override;
};

#endif // OGGNALIVE_QT_OGGNALIVEADDRESSVALIDATOR_H
